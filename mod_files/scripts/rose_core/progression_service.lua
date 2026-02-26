local progression_service = {}

local DEFAULT_GROWTH_EXPONENT = 1.2
local DEFAULT_GROWTH_SCALE = 10
local DEFAULT_GROWTH_PRECISION = 0.1

local function to_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

function progression_service.ResolveGoldValue(item)
    if item == nil then
        return 0
    end

    if item.prefab == "goldnugget" then
        return 1
    end

    if item.components == nil or item.components.tradable == nil then
        return 0
    end

    local gold_value = to_number(item.components.tradable.goldvalue, 0)
    if gold_value <= 0 then
        return 0
    end

    return gold_value
end

function progression_service.CanUpgradeByItem(item, accepted_prefab)
    if item == nil then
        return false
    end

    local gold_value = progression_service.ResolveGoldValue(item)
    if accepted_prefab ~= nil and item.prefab ~= accepted_prefab and gold_value <= 0 then
        return false
    end

    return gold_value > 0
end

function progression_service.ComputeBonusByLevel(level, growth_curve)
    local safe_level = math.max(to_number(level, 0), 0)
    if safe_level <= 0 then
        return 0
    end

    growth_curve = growth_curve or {}
    local exponent = to_number(growth_curve.exponent, DEFAULT_GROWTH_EXPONENT)
    local scale = to_number(growth_curve.scale, DEFAULT_GROWTH_SCALE)
    local precision = to_number(growth_curve.precision, DEFAULT_GROWTH_PRECISION)

    local factor = math.exp(exponent * math.log10(safe_level))
    return precision * math.floor(scale * factor)
end

---@class RoseProgressResult
---@field applied boolean 是否成功应用
---@field delta number 实际增加量
---@field level? number 更新后的等级
---@field bonus? number 更新后的伤害加成

---应用经验/等级成长进度
---@param damage_state table 当前伤害状态数据
---@param delta number 增加量
---@param growth_curve table|nil 曲线配置表
---@return RoseProgressResult
function progression_service.ApplyProgress(damage_state, delta, growth_curve)
    if type(damage_state) ~= "table" then
        return {
            applied = false,
            delta = 0,
        }
    end

    local safe_delta = to_number(delta, 0)
    if safe_delta <= 0 then
        return {
            applied = false,
            delta = 0,
            level = to_number(damage_state.level, 0),
            bonus = to_number(damage_state.bonus, 0),
        }
    end

    local current_level = to_number(damage_state.level, 0)
    local next_level = math.max(current_level + safe_delta, 0)
    local next_bonus = progression_service.ComputeBonusByLevel(next_level, growth_curve)

    damage_state.level = next_level
    damage_state.bonus = next_bonus

    return {
        applied = true,
        delta = safe_delta,
        level = next_level,
        bonus = next_bonus,
    }
end

return progression_service
