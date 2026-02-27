local ability = {
    id = "nightvision_toggle",
}

local STATE_KEY_ENABLED = "enabled"
local OWNER_CACHE_KEY = "nightvision_toggle_owner"
local NIGHTVISION_NETVAR_NAME = "_nightvision_enabled"
local SANITY_MODIFIER_KEY = "rose_weapon_nightvision_sanity"
local DEFAULT_EXTRA_SANITY_DRAIN_PER_MIN = 10
local SECONDS_PER_MINUTE = 60
local TOGGLE_SOUND_ON = "dontstarve_DLC001/common/moggles_on"
local TOGGLE_SOUND_OFF = "dontstarve_DLC001/common/moggles_off"
local EVENT_SENTIENT_NIGHTVISION_TOGGLED = "rose_sentient_nightvision_toggled"

local function get_owner(inst, fallback_owner)
    if fallback_owner ~= nil then
        return fallback_owner
    end

    if inst == nil or inst.components == nil or inst.components.inventoryitem == nil then
        return nil
    end

    return inst.components.inventoryitem.owner
end

local function is_equipped(inst)
    return inst ~= nil
        and inst.components ~= nil
        and inst.components.equippable ~= nil
        and inst.components.equippable:IsEquipped()
end

local function set_enabled_state(runtime, enabled)
    local state = runtime:GetAbilityState(ability.id)
    state[STATE_KEY_ENABLED] = enabled == true
end

local function get_enabled_state(runtime)
    local state = runtime:GetAbilityState(ability.id)
    return state[STATE_KEY_ENABLED] == true
end

local function resolve_extra_sanity_drain(config)
    local drain_per_min = DEFAULT_EXTRA_SANITY_DRAIN_PER_MIN
    if type(config) == "table" and type(config.extra_sanity_drain_per_min) == "number" then
        drain_per_min = math.max(0, config.extra_sanity_drain_per_min)
    end

    return -drain_per_min / SECONDS_PER_MINUTE
end

local function update_extra_sanity_drain(owner, runtime, config, enabled)
    if owner == nil or owner.components == nil or owner.components.sanity == nil then
        return
    end

    local external_modifiers = owner.components.sanity.externalmodifiers
    if external_modifiers == nil then
        return
    end

    if enabled then
        external_modifiers:SetModifier(runtime.inst, resolve_extra_sanity_drain(config), SANITY_MODIFIER_KEY)
        return
    end

    external_modifiers:RemoveModifier(runtime.inst, SANITY_MODIFIER_KEY)
end

local function sync_nightvision_tag(inst, enabled)
    if inst == nil then
        return
    end

    if enabled then
        inst:AddTag("nightvision")
    else
        inst:RemoveTag("nightvision")
    end

    local netvar = inst[NIGHTVISION_NETVAR_NAME]
    if netvar ~= nil and netvar.set ~= nil then
        netvar:set(enabled)
    end
end

local function refresh_owner_vision(owner, inst)
    if owner == nil then
        return
    end

    owner:PushEvent("equip", {
        item = inst,
        eslot = EQUIPSLOTS.HANDS,
    })
end

local function play_toggle_sound(owner, enabled)
    if owner == nil or owner.SoundEmitter == nil then
        return
    end

    owner.SoundEmitter:PlaySound(enabled and TOGGLE_SOUND_ON or TOGGLE_SOUND_OFF)
end

local function apply_nightvision_state(runtime, owner, config, enabled, play_sound)
    local inst = runtime ~= nil and runtime.inst or nil
    sync_nightvision_tag(inst, enabled)
    update_extra_sanity_drain(owner, runtime, config, enabled)
    refresh_owner_vision(owner, inst)

    if play_sound then
        play_toggle_sound(owner, enabled)
    end
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param config table
---@description 装备时强制默认关闭夜视, 等待玩家右键主动开启.
function ability.OnEquip(runtime, owner, config)
    local current_owner = get_owner(runtime.inst, owner)
    local previous_owner = runtime.cache[OWNER_CACHE_KEY]
    if previous_owner ~= nil and previous_owner ~= current_owner then
        update_extra_sanity_drain(previous_owner, runtime, config, false)
    end

    runtime.cache[OWNER_CACHE_KEY] = current_owner
    set_enabled_state(runtime, false)
    apply_nightvision_state(runtime, current_owner, config, false, false)
end

---@param context table
---@param config table
---@description 右键切换夜视, 开启时附加额外理智消耗, 关闭时移除.
function ability.OnUseItem(context, config)
    if context == nil or context.runtime == nil then
        return
    end

    local runtime = context.runtime
    local inst = context.inst or runtime.inst
    if not is_equipped(inst) then
        return
    end

    local owner = get_owner(inst, context.doer)
    if owner == nil then
        return
    end

    local enabled = not get_enabled_state(runtime)
    set_enabled_state(runtime, enabled)
    runtime.cache[OWNER_CACHE_KEY] = owner
    apply_nightvision_state(runtime, owner, config, enabled, true)
    inst:PushEvent(EVENT_SENTIENT_NIGHTVISION_TOGGLED, {
        enabled = enabled,
        owner = owner,
    })
    context.handled = true
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param config table
---@description 卸下时兜底关闭夜视并清理额外理智消耗修饰器.
function ability.OnUnequip(runtime, owner, config)
    local current_owner = owner or runtime.cache[OWNER_CACHE_KEY]
    set_enabled_state(runtime, false)
    apply_nightvision_state(runtime, current_owner, config, false, false)
    runtime.cache[OWNER_CACHE_KEY] = nil
end

---@param runtime component_rose_weapon_runtime
---@param config table
---@description 组件移除时执行同等清理逻辑.
function ability.OnRemove(runtime, config)
    ability.OnUnequip(runtime, nil, config)
end

return ability
