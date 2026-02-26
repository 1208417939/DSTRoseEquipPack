local ability = {
    id = "behead",
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
---@description 攻击前触发，根据目标当前生命值百分比进行斩杀判定，血量越低斩杀伤害倍率越高。
function ability.OnAttackPre(context, config)
    local target = context.target
    if target == nil or target.components == nil or target.components.health == nil then
        return
    end

    local target_hp_percent = target.components.health:GetPercent()
    local health_percent_threshold = get_number(config.health_percent_threshold, 0)
    if health_percent_threshold <= 0 or target_hp_percent > health_percent_threshold then
        return
    end

    local damage_multiplier = get_number(config.damage_multiplier, 1)
    local beheaded_k = (1 - damage_multiplier) / health_percent_threshold
    local beheaded_c = damage_multiplier
    local behead_multiplier = beheaded_k * target_hp_percent + beheaded_c
    context.damage_multiplier = (context.damage_multiplier or 1) * math.max(behead_multiplier, 1)

    local fx = SpawnPrefab("ghostlyelixir_retaliation_dripfx")
    if fx ~= nil then
        fx.Transform:SetScale(0.1 * math.random(5, 13), 0.1 * math.random(5, 13), 0.1 * math.random(5, 13))
        fx.Transform:SetPosition(context.inst.Transform:GetWorldPosition())
    end
end

return ability
