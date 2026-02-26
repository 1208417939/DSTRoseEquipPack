local ability = {
    id = "ice",
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
---@description 攻击命中后触发，按概率为目标叠加冰冻层数，并触发碎冰特效。
function ability.OnAttackPost(context, config)
    local target = context.target
    if target == nil or target.components == nil then
        return
    end

    local chance = normalize_chance(config.chance, 0)
    if math.random() > chance then
        return
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(get_number(config.coldness, 0))
        target.components.freezable:SpawnShatterFX()
    end
end

return ability
