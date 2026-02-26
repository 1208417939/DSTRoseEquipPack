local damage_pipeline = {}

local function to_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

---@class RoseDamagePipelineResult
---@field base_damage number 基础伤害
---@field progression_bonus number 成长伤害
---@field panel_damage number 面板伤害
---@field multiplier number 倍率
---@field final_damage number 最终伤害
---@field bonus_damage number 额外附加伤害

---计算伤害管线最终结果
---@param base_damage number
---@param progression_bonus number
---@param damage_multiplier number
---@return RoseDamagePipelineResult
function damage_pipeline.Compute(base_damage, progression_bonus, damage_multiplier)
    local safe_base_damage = to_number(base_damage, 0)
    local safe_progression_bonus = to_number(progression_bonus, 0)
    local safe_multiplier = math.max(to_number(damage_multiplier, 1), 1)

    local panel_damage = safe_base_damage + safe_progression_bonus
    local final_damage = panel_damage * safe_multiplier
    local bonus_damage = math.max(final_damage - safe_base_damage, 1)

    return {
        base_damage = safe_base_damage,
        progression_bonus = safe_progression_bonus,
        panel_damage = panel_damage,
        multiplier = safe_multiplier,
        final_damage = final_damage,
        bonus_damage = bonus_damage,
    }
end

return damage_pipeline
