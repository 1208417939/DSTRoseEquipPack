local ability = {
    id = "aoe",
}

local AOE_TASK_KEY = "aoe_wait_task"
local AOE_HIT_RADIUS_PADDING = 3.5
local AOE_MUST_TAGS = { "_combat" }
local AOE_CANT_TAGS = {
    "INLIMBO",
    "notarget",
    "noattack",
    "flight",
    "invisible",
    "playerghost",
    "wall",
    "companion",
    "abigail",
    "shadowminion",
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

---@return table
---@description 按 PVP 状态构建范围伤害排除标签。
local function build_aoe_exclude_tags()
    local tags = {}
    for i = 1, #AOE_CANT_TAGS do
        tags[i] = AOE_CANT_TAGS[i]
    end

    if TheNet ~= nil and not TheNet:GetPVPEnabled() then
        table.insert(tags, "player")
    end

    return tags
end

---@param runtime component_rose_weapon_runtime
---@description 取消并清理 AOE 连击窗口定时任务。
local function clear_aoe_wait_task(runtime)
    if runtime == nil or runtime.cache == nil then
        return
    end

    local wait_task = runtime.cache[AOE_TASK_KEY]
    if wait_task ~= nil then
        wait_task:Cancel()
        runtime.cache[AOE_TASK_KEY] = nil
    end
end

---@param context table
---@param attack_radius number
---@param damage_multiplier number
---@description 执行范围伤害，参考官方 Combat 结算与棱镜兰草目标筛选逻辑。
local function do_aoe_attack(context, attack_radius, damage_multiplier)
    local target = context.target
    local attacker = context.attacker
    local inst = context.inst
    if target == nil or attacker == nil or inst == nil or not target:IsValid() then
        return
    end

    if attacker.components == nil or attacker.components.combat == nil then
        return
    end

    local attacker_combat = attacker.components.combat
    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, attack_radius, AOE_MUST_TAGS, build_aoe_exclude_tags())
    local hit_count = 0

    for _, ent in ipairs(ents) do
        if attacker.components == nil or attacker.components.combat == nil or not attacker:IsValid() then
            break
        end

        if ent ~= target and ent ~= attacker and ent:IsValid() and ent.entity ~= nil and ent.entity:IsVisible() then
            local hit_radius = AOE_HIT_RADIUS_PADDING + ent:GetPhysicsRadius(0)
            if ent:GetDistanceSqToPoint(x, y, z) <= hit_radius * hit_radius and ent.components ~= nil and ent.components.combat ~= nil and ent.components.health ~= nil and not ent.components.health:IsDead() then
                if attacker_combat:IsValidTarget(ent) then
                    attacker:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil })
                    local damage, spdamage = attacker_combat:CalcDamage(ent, inst, damage_multiplier)
                    ent.components.combat:GetAttacked(attacker, damage, inst, nil, spdamage)
                    hit_count = hit_count + 1
                end
            end
        end
    end

    if hit_count > 0 then
        local fx = SpawnPrefab("electrichitsparks")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end
    end
end

---@param context table
---@param config table
---@return boolean
---@description 刷新连击状态并返回当前命中是否应触发 AOE。
local function should_trigger_aoe(context, config)
    local runtime = context.runtime
    local state = runtime:GetAbilityState(ability.id)
    state.aoe_hit_count = (state.aoe_hit_count or 0) + 1

    local trigger_hit_count = math.max(1, math.floor(get_number(config.trigger_hit_count, 1)))
    if trigger_hit_count <= 1 then
        state.aoe_hit_count = 0
        clear_aoe_wait_task(runtime)
        return true
    end

    clear_aoe_wait_task(runtime)

    if state.aoe_hit_count >= trigger_hit_count then
        state.aoe_hit_count = 0
        return true
    end

    local trigger_window_time = math.max(0.1, get_number(config.trigger_window_time, 5))
    if context.inst ~= nil then
        runtime.cache[AOE_TASK_KEY] = context.inst:DoTaskInTime(trigger_window_time, function()
            state.aoe_hit_count = 0
            runtime.cache[AOE_TASK_KEY] = nil
        end)
    end

    return false
end

---@param context table
---@param config table
---@description 攻击命中后触发，累计攻击次数，达到阈值时触发范围伤害。
function ability.OnAttackPost(context, config)
    local aoe_damage_multiplier = math.max(0, get_number(config.aoe_damage_multiplier, 0))
    local attack_radius = math.max(0.1, get_number(config.attack_radius, 4))

    if aoe_damage_multiplier <= 0 then
        return
    end

    if should_trigger_aoe(context, config) then
        do_aoe_attack(context, attack_radius, aoe_damage_multiplier)
    end
end

return ability
