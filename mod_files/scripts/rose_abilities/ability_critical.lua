local ability = {
    id = "critical",
}

local CHANCE_BOTTOM = 100

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
---@description 攻击前触发，判定暴击概率。未触发时累积伪随机补偿，触发时给予高额伤害倍率修正。
function ability.OnAttackPre(context, config)
    local state = context.runtime:GetAbilityState(ability.id)
    state.miss_critical_hit_count = state.miss_critical_hit_count or 0

    local min_chance = get_number(config.min_chance, 0)
    local max_chance = get_number(config.max_chance, 0)
    local chance_add_per_miss = get_number(config.chance_add_per_miss, 0)
    local max_damage_multiplier = get_number(config.max_damage_multiplier, 1)
    local min_damage_multiplier = get_number(config.min_damage_multiplier, 1)
    local damage_multiplier_reduce_per_miss = get_number(config.damage_multiplier_reduce_per_miss, 0)

    local chance = math.min(min_chance + state.miss_critical_hit_count * chance_add_per_miss, max_chance)
    if math.random(0, CHANCE_BOTTOM) > chance then
        state.miss_critical_hit_count = state.miss_critical_hit_count + 1
        return
    end

    local critical_mult = math.max(max_damage_multiplier - state.miss_critical_hit_count * damage_multiplier_reduce_per_miss, min_damage_multiplier)
    context.damage_multiplier = (context.damage_multiplier or 1) * math.max(critical_mult, 1)

    if context.attacker ~= nil and context.attacker.SoundEmitter ~= nil then
        context.attacker.SoundEmitter:PlaySound("dontstarve/common/whip_large")
    end

    if context.target ~= nil and context.target.Transform ~= nil then
        local fx = SpawnPrefab("impact")
        if fx ~= nil and fx.Transform ~= nil then
            fx.Transform:SetScale(math.random(1, 5), math.random(1, 5), math.random(1, 5))
            fx.Transform:SetPosition(context.target.Transform:GetWorldPosition())
        end
    end
end

return ability
