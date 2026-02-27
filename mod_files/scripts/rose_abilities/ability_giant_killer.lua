local ability = {
    id = "giant_killer",
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

---@param value number
---@param min_value number
---@param max_value number
---@return number
---@description 对数值进行上下限约束。
local function clamp(value, min_value, max_value)
    if value < min_value then
        return min_value
    end
    if value > max_value then
        return max_value
    end
    return value
end

---@param target ent|nil
---@return table|nil
---@description 获取目标 health 组件，缺失则返回 nil。
local function get_target_health(target)
    if target == nil or target.components == nil then
        return nil
    end
    return target.components.health
end

---@param target_health table
---@param config table
---@return number|nil
---@description
---返回目标最大生命值（命中巨兽判定时）；
---未命中判定返回 nil。
local function resolve_trigger_target_max_health(target_health, config)
    local target_max_health = get_number(target_health.maxhealth, 0)
    local giant_health_threshold = math.max(0, get_number(config.giant_health_threshold, 0))
    if target_max_health < giant_health_threshold then
        return nil
    end

    local health_percent_threshold = clamp(get_number(config.health_percent_threshold, 1), 0, 1)
    local current_percent = clamp(get_number(target_health:GetPercent(), 0), 0, 1)
    if current_percent <= health_percent_threshold then
        return nil
    end

    return target_max_health
end

---@param context table
---@param config table
---@description
---攻击前触发：命中巨兽判定后提供固定倍率增伤，
---并缓存一次按最大生命值比例计算的额外伤害，交给 OnAttackPost 落地。
function ability.OnAttackPre(context, config)
    config = config or {}
    local target_health = get_target_health(context.target)
    if target_health == nil then
        return
    end

    local target_max_health = resolve_trigger_target_max_health(target_health, config)
    if target_max_health == nil then
        return
    end

    local damage_multiplier = math.max(get_number(config.damage_multiplier, 1), 1)
    context.damage_multiplier = (context.damage_multiplier or 1) * damage_multiplier

    local max_health_bonus_percent = math.max(0, get_number(config.max_health_bonus_percent, 0))
    if max_health_bonus_percent > 0 and target_max_health > 0 then
        local bonus_damage = target_max_health * (max_health_bonus_percent / 100)
        if bonus_damage > 0 then
            context.giant_killer_bonus_damage = (context.giant_killer_bonus_damage or 0) + bonus_damage
        end
    end

    local fx = SpawnPrefab("fx_boat_pop")
    if fx ~= nil then
        fx.Transform:SetScale(0.1 * math.random(5, 13), 0.1 * math.random(5, 13), 0.1 * math.random(5, 13))
        fx.Transform:SetPosition(context.target.Transform:GetWorldPosition())
    end
end

---@param context table
---@param _config table
---@description 攻击后触发：对巨兽追加一次百分比补刀伤害。
function ability.OnAttackPost(context, _config)
    local bonus_damage = get_number(context.giant_killer_bonus_damage, 0)
    if bonus_damage <= 0 then
        return
    end

    local attacker = context.attacker
    local target = context.target
    if attacker == nil or target == nil or target.components == nil or target.components.combat == nil then
        return
    end

    target.components.combat:GetAttacked(attacker, bonus_damage, context.inst)

    if context.damage_result ~= nil then
        context.damage_result.giant_killer_bonus_damage = bonus_damage
    end
end

return ability
