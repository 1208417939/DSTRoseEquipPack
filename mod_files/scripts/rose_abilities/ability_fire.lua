local ability = {
    id = "fire",
}

local FIRE_FX_FIELD = "rose_fire_fx"
local FIRE_TASK_FIELD = "rose_fire_task"

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

---@param value any
---@param default_value number
---@return number
---@description 标准化概率值，若是大于 1 的数字则缩小 100 倍，并限制在 0~1 之间。
local function normalize_chance(value, default_value)
    local chance = get_number(value, default_value)
    if chance > 1 then
        chance = chance / 100
    end
    return math.min(math.max(chance, 0), 1)
end

---@param context table
---@param config table
---@description 攻击命中后触发，按概率给目标施加点燃状态并附加持续伤害（DOT），包含存活与刷新机制。
function ability.OnAttackPost(context, config)
    local target = context.target
    local attacker = context.attacker
    if target == nil or attacker == nil then
        return
    end

    local chance = normalize_chance(config.chance, 0)
    if math.random() > chance then
        return
    end

    if target[FIRE_FX_FIELD] == nil then
        target[FIRE_FX_FIELD] = SpawnPrefab("campfirefire")
        if target[FIRE_FX_FIELD] ~= nil then
            target[FIRE_FX_FIELD].entity:SetParent(target.entity)
            target[FIRE_FX_FIELD].entity:AddFollower()
            target[FIRE_FX_FIELD].Follower:FollowSymbol(target.GUID, nil, 0, -20, 0)
        end
    end

    if target[FIRE_TASK_FIELD] ~= nil then
        return
    end

    local tick_period = math.max(0.1, get_number(config.tick_period, 1))
    local tick_damage = get_number(config.tick_damage, 0)
    local effect_duration = math.max(0.1, get_number(config.effect_duration, 1))

    target[FIRE_TASK_FIELD] = target:DoPeriodicTask(tick_period, function()
        if attacker == nil or (attacker.IsValid ~= nil and not attacker:IsValid()) then
            return
        end

        if target ~= nil and target.components ~= nil and target.components.combat ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
            target.components.combat:GetAttacked(attacker, tick_damage)
        end
    end)

    target:DoTaskInTime(effect_duration, function()
        if target[FIRE_TASK_FIELD] ~= nil then
            target[FIRE_TASK_FIELD]:Cancel()
            target[FIRE_TASK_FIELD] = nil
        end
        if target[FIRE_FX_FIELD] ~= nil then
            target[FIRE_FX_FIELD]:Remove()
            target[FIRE_FX_FIELD] = nil
        end
    end)
end

return ability
