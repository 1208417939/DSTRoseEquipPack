local ability = {
    id = "aoe",
}

local AOE_TASK_KEY = "aoe_wait_task"

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

---@param context table
---@param attack_radius number
---@param damage number
---@description 执行范围伤害，遍历半径内非友方实体并推送受击事件。
local function do_aoe_attack(context, attack_radius, damage)
    local target = context.target
    local attacker = context.attacker
    local inst = context.inst
    if target == nil or attacker == nil or inst == nil then
        return
    end

    if attacker.components == nil or attacker.components.combat == nil then
        return
    end

    local x, y, z = target.Transform:GetWorldPosition()
    local must_tags = { "_combat" }
    local filter_tags = { "player", "companion", "wall", "INLIMBO", "abigail", "shadowminion" }
    local ents = TheSim:FindEntities(x, y, z, attack_radius, must_tags, filter_tags)
    for _, ent in ipairs(ents) do
        if ent ~= target and ent ~= attacker and ent.components ~= nil and ent.components.combat ~= nil and ent.components.health ~= nil then
            if attacker.components.combat:IsValidTarget(ent) then
                attacker:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil })
                ent.components.combat:GetAttacked(attacker, damage)
                SpawnPrefab("electrichitsparks").Transform:SetPosition(target.Transform:GetWorldPosition())
            end
        end
    end
end

---@param context table
---@param config table
---@description 攻击命中后触发，累计攻击次数，达到阈值时触发范围伤害。
function ability.OnAttackPost(context, config)
    local runtime = context.runtime
    local state = runtime:GetAbilityState(ability.id)
    state.aoe_hit_count = (state.aoe_hit_count or 0) + 1

    local trigger_hit_count = math.max(1, math.floor(get_number(config.trigger_hit_count, 1)))
    local trigger_window_time = math.max(0.1, get_number(config.trigger_window_time, 5))
    local aoe_damage_multiplier = get_number(config.aoe_damage_multiplier, 0)
    local attack_radius = math.max(0.1, get_number(config.attack_radius, 4))

    if state.aoe_hit_count == trigger_hit_count + 1 then
        local wait_task = runtime.cache[AOE_TASK_KEY]
        if wait_task ~= nil then
            wait_task:Cancel()
            runtime.cache[AOE_TASK_KEY] = nil
        end

        local base_damage = runtime:GetCurrentDamage()
        local aoe_damage = base_damage * aoe_damage_multiplier
        do_aoe_attack(context, attack_radius, aoe_damage)
        state.aoe_hit_count = 0
    elseif state.aoe_hit_count == trigger_hit_count then
        runtime.cache[AOE_TASK_KEY] = context.inst:DoTaskInTime(trigger_window_time, function()
            state.aoe_hit_count = 0
            if runtime.cache[AOE_TASK_KEY] ~= nil then
                runtime.cache[AOE_TASK_KEY]:Cancel()
                runtime.cache[AOE_TASK_KEY] = nil
            end
        end)
    end
end

return ability
