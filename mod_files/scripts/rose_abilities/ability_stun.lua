local ability = {
    id = "stun",
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
---@description 攻击命中后触发，基于概率麻痹目标（打断行动并停止思考）一定持续时间。
function ability.OnAttackPost(context, config)
    local target = context.target
    if target == nil then
        return
    end

    local chance = normalize_chance(config.chance, 0)
    if math.random() > chance then
        return
    end

    local stun_tag = context.inst.prefab .. "_stun"
    if target.brain == nil or target.components == nil or target.components.combat == nil or target.components.locomotor == nil or target:HasTag(stun_tag) then
        return
    end

    target:AddTag(stun_tag)
    SpawnPrefab("lightning_rod_fx").Transform:SetPosition(target.Transform:GetWorldPosition())
    target.components.locomotor:Stop()
    target.brain:Stop()
    target:DoTaskInTime(math.max(0.1, get_number(config.stun_duration, 1)), function(target_inst)
        if target_inst.brain ~= nil then
            target_inst.brain:Start()
        end
        target_inst:RemoveTag(stun_tag)
    end)
end

return ability
