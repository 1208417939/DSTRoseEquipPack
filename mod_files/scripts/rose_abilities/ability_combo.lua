local ability = {
    id = "combo",
}

local RESET_TASK_KEY = "combo_reset_task"

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
---@description 攻击前触发，累计连击次数并刷新重置定时器，根据当前连击数增加伤害倍率。
function ability.OnAttackPre(context, config)
    local runtime = context.runtime
    local state = runtime:GetAbilityState(ability.id)
    state.combo_hit_count = state.combo_hit_count or 0

    local max_combo_count = math.max(1, math.floor(get_number(config.max_combo_count, 1)))
    local combo_damage_multiplier = get_number(config.combo_damage_multiplier, 0)
    local combo_reset_time = math.max(0.1, get_number(config.combo_reset_time, 2))

    state.combo_hit_count = math.min(state.combo_hit_count + 1, max_combo_count)

    local reset_task = runtime.cache[RESET_TASK_KEY]
    if reset_task ~= nil then
        reset_task:Cancel()
        runtime.cache[RESET_TASK_KEY] = nil
    end

    runtime.cache[RESET_TASK_KEY] = context.inst:DoTaskInTime(combo_reset_time, function()
        state.combo_hit_count = 0
        runtime.cache[RESET_TASK_KEY] = nil
    end)

    local multiplier = 1 + combo_damage_multiplier * state.combo_hit_count
    context.damage_multiplier = (context.damage_multiplier or 1) * math.max(multiplier, 1)
end

return ability
