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

---@param context table
---@param config table
---@description 攻击前触发，针对高生命值目标（满足巨人阈值）根据其当前生命值百分比附加额外伤害倍率。
function ability.OnAttackPre(context, config)
    local target = context.target
    if target == nil or target.components == nil or target.components.health == nil then
        return
    end

    local target_health = target.components.health
    local giant_health_threshold = get_number(config.giant_health_threshold, 0)
    local health_percent_threshold = get_number(config.health_percent_threshold, 1)
    if health_percent_threshold >= 1 or target_health.maxhealth < giant_health_threshold or target_health:GetPercent() < health_percent_threshold then
        return
    end

    local damage_multiplier = get_number(config.damage_multiplier, 1)
    local giantkiller_k = (damage_multiplier - 1) / (1 - health_percent_threshold)
    local giantkiller_c = damage_multiplier - giantkiller_k
    local giant_multiplier = giantkiller_k * target_health:GetPercent() + giantkiller_c
    context.damage_multiplier = (context.damage_multiplier or 1) * math.max(giant_multiplier, 1)

    local fx = SpawnPrefab("fx_boat_pop")
    if fx ~= nil then
        fx.Transform:SetScale(0.1 * math.random(5, 13), 0.1 * math.random(5, 13), 0.1 * math.random(5, 13))
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

return ability
