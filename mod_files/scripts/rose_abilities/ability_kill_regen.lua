local ability = {
    id = "kill_regen",
}

---@param value any
---@param default_value number
---@return number
---@description 安全读取数值配置，非 number 时回退默认值。
local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

---@param owner table
---@param data table
---@param config table
---@description 击杀事件触发的回调，基于目标最大生命值百分比为武器拥有者恢复生命。
local function on_killed(owner, data, config)
    if owner == nil or owner.components == nil or owner.components.health == nil then
        return
    end

    local victim = data ~= nil and data.victim or nil
    if victim == nil or victim.components == nil or victim.components.health == nil then
        return
    end

    local heal_percent = get_number(config.heal_percent, 0)
    if heal_percent <= 0 then
        return
    end

    local heal_multiplier = heal_percent / 100
    local victim_hp = math.ceil(victim.components.health.maxhealth)
    local heal = math.max(1, math.ceil(victim_hp * heal_multiplier))
    owner.components.health:DoDelta(heal)
end

---@param runtime table
---@param owner table
---@param config table
---@description 装备时监听拥有者的击杀事件。
function ability.OnEquip(runtime, owner, config)
    if owner == nil then
        return
    end

    local cache = runtime.cache
    if cache.kill_regen_owner ~= nil and cache.kill_regen_callback ~= nil then
        cache.kill_regen_owner:RemoveEventCallback("killed", cache.kill_regen_callback)
    end

    cache.kill_regen_owner = owner
    cache.kill_regen_callback = function(inst, data)
        on_killed(inst, data, config)
    end

    owner:ListenForEvent("killed", cache.kill_regen_callback)
end

---@param runtime table
---@param owner table
---@param _config table
---@description 卸下时移除击杀事件监听。
function ability.OnUnequip(runtime, owner, _config)
    local cache = runtime.cache
    if cache.kill_regen_owner == nil or cache.kill_regen_callback == nil then
        return
    end

    local event_owner = owner or cache.kill_regen_owner
    event_owner:RemoveEventCallback("killed", cache.kill_regen_callback)
    cache.kill_regen_owner = nil
    cache.kill_regen_callback = nil
end

return ability
