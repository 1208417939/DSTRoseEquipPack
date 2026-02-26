local ability = {
    id = "waterproof",
}

local OWNER_CACHE_KEY = "waterproof_owner"
local LEGACY_INHERENT_KEY = "waterproof_legacy_inherent"
local MODIFIER_KEY = "rose_weapon_waterproof"

---@param value number
---@return number
---@description 将百分比值安全转换为 0~1 防水比例。
local function to_ratio(value)
    return math.max(0, math.min(1, value / 100))
end

local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

---@param moisture component_moisture
---@param runtime component_rose_weapon_runtime
---@param ratio number
---@description 优先走防水修饰器；若不可用则降级写入 inherent 防水值。
local function apply_waterproof(moisture, runtime, ratio)
    if moisture.waterproofnessmodifiers ~= nil and moisture.waterproofnessmodifiers.SetModifier ~= nil then
        moisture.waterproofnessmodifiers:SetModifier(runtime.inst, ratio, MODIFIER_KEY)
        runtime.cache[LEGACY_INHERENT_KEY] = nil
        return
    end

    runtime.cache[LEGACY_INHERENT_KEY] = moisture.inherentWaterproofness or 0
    moisture:SetInherentWaterproofness(ratio)
end

---@param moisture component_moisture
---@param runtime component_rose_weapon_runtime
---@description 移除防水修饰器；若在降级路径中则恢复旧的 inherent 防水值。
local function clear_waterproof(moisture, runtime)
    if moisture.waterproofnessmodifiers ~= nil and moisture.waterproofnessmodifiers.RemoveModifier ~= nil then
        moisture.waterproofnessmodifiers:RemoveModifier(runtime.inst, MODIFIER_KEY)
        runtime.cache[LEGACY_INHERENT_KEY] = nil
        return
    end

    local old_inherent = runtime.cache[LEGACY_INHERENT_KEY]
    moisture:SetInherentWaterproofness(type(old_inherent) == "number" and old_inherent or 0)
    runtime.cache[LEGACY_INHERENT_KEY] = nil
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param config table
---@description 装备时应用防水加成。
function ability.OnEquip(runtime, owner, config)
    if owner == nil or owner.components == nil or owner.components.moisture == nil then
        return
    end

    local waterproof_percent = get_number(config.waterproof_percent, 0)
    local waterproof_ratio = to_ratio(waterproof_percent)
    apply_waterproof(owner.components.moisture, runtime, waterproof_ratio)
    runtime.cache[OWNER_CACHE_KEY] = owner
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param _config table
---@description 卸下时移除防水加成。
function ability.OnUnequip(runtime, owner, _config)
    local target_owner = owner or runtime.cache[OWNER_CACHE_KEY]
    if target_owner == nil or target_owner.components == nil or target_owner.components.moisture == nil then
        runtime.cache[OWNER_CACHE_KEY] = nil
        runtime.cache[LEGACY_INHERENT_KEY] = nil
        return
    end

    clear_waterproof(target_owner.components.moisture, runtime)
    runtime.cache[OWNER_CACHE_KEY] = nil
end

---@param runtime component_rose_weapon_runtime
---@param _config table
---@description 组件移除时执行兜底清理。
function ability.OnRemove(runtime, _config)
    ability.OnUnequip(runtime, nil, {})
end

return ability
