local weapon_data_resolver = require("rose_core/rose_weapon_data_resolver")
local data_cfg = weapon_data_resolver.resolve_weapon_data("oceantrident")
if data_cfg == nil then
    error("Failed to resolve weapon data for oceantrident")
end

local weapon_factory = require("rose_core/rose_weapon_factory")
local oceantrident_def = require("rose_defs/weapon_def_builder").build("oceantrident")
local sakura_fx = require("prefabs/prefab_sakura_fx")
local prefab_tuning = require("rose_prefab/rose_prefab_tuning")
local inventory_image_anim = require("rose_prefab/prefab_inventory_image_anim")
local component_installers = require("rose_prefab/prefab_component_installers")

local prefab_id = data_cfg.prefab_id

local assets = {
    Asset("ANIM", "anim/" .. prefab_id .. ".zip"),
    Asset("ANIM", "anim/swap_" .. prefab_id .. ".zip"),
    Asset("ATLAS", "images/" .. prefab_id .. ".xml"),
    Asset("ATLAS", "images/frames/" .. data_cfg.inventory_image_anim.atlas_xml_name .. ".xml"),
}

local prefabs = {}
local sakura_fx_controller = sakura_fx.build_controller({
    enabled = data_cfg.sakura_particle.enabled,
    fx_prefab_name = prefab_id .. "_sakura_rain",
})
local inventory_image_controller = inventory_image_anim.build_controller(data_cfg.inventory_image_anim)

local function reticule_target_function(_inst)
    if ThePlayer == nil or ThePlayer.entity == nil then
        local x, y, z = _inst.Transform:GetWorldPosition()
        return Vector3(x, y, z)
    end
    return Vector3(ThePlayer.entity:LocalToWorldSpace(3.5, 0.001, 0))
end

local function reticule_valid_fn(_inst, _reticule, target_pos, _alwayspassable, _allowwater, _deployradius)
    if target_pos == nil or TheWorld == nil or TheWorld.Map == nil then
        return false
    end
    return TheWorld.Map:IsOceanAtPoint(target_pos.x, target_pos.y, target_pos.z, false)
        and not TheWorld.Map:IsGroundTargetBlocked(target_pos)
end

local function is_light_enabled()
    return data_cfg.equip ~= nil and data_cfg.equip.light_enabled == true
end

local function set_weapon_light(inst, enabled)
    if inst.Light ~= nil then
        inst.Light:Enable(enabled == true)
    end
end

local function on_equip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_" .. prefab_id, "swap_" .. prefab_id)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    set_weapon_light(inst, is_light_enabled())

    local runtime = inst.components.rose_weapon_runtime
    if runtime ~= nil then
        runtime:OnEquip(owner)
    end

    sakura_fx_controller.set_emitter_state(inst, true)
end

local function on_unequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    set_weapon_light(inst, false)

    local runtime = inst.components.rose_weapon_runtime
    if runtime ~= nil then
        runtime:OnUnequip(owner)
    end

    sakura_fx_controller.set_emitter_state(inst, false)
end

local function on_attack(inst, attacker, target)
    local runtime = inst.components.rose_weapon_runtime
    if runtime ~= nil then
        runtime:OnAttack(inst, attacker, target)
    end
end

local function can_accept_item(inst, item)
    local runtime = inst.components.rose_weapon_runtime
    if runtime == nil then
        return false
    end

    return runtime:CanAcceptTradeItem(item)
end

local function on_accept_item(inst, giver, item)
    local runtime = inst.components.rose_weapon_runtime
    if runtime ~= nil then
        runtime:OnAcceptItem(inst, giver, item)
    end
end

local function on_cast_spell(inst, target, pos, doer)
    local runtime = inst.components.rose_weapon_runtime
    if runtime ~= nil then
        runtime:OnCastSpell(inst, target, pos, doer)
    end
end

local function can_cast_spell(doer, target, pos, spell_inst)
    if spell_inst == nil or spell_inst.components == nil then
        return false
    end

    local runtime = spell_inst.components.rose_weapon_runtime
    if runtime == nil then
        return false
    end

    return runtime:CanCastSpell(spell_inst, target, pos, doer)
end

local function on_pre_load(inst, _data)
    sakura_fx_controller.preload_restore(inst)
end

local function on_inventory_dropped(inst)
    set_weapon_light(inst, false)
    sakura_fx_controller.set_emitter_state(inst, false)
end

local function on_remove_entity(inst)
    sakura_fx_controller.set_emitter_state(inst, false)
    inventory_image_controller.cleanup(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(prefab_id)
    inst.AnimState:SetBuild(prefab_id)
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = reticule_target_function
    inst.components.reticule.twinstickcheckscheme = true
    inst.components.reticule.twinstickmode = 1
    inst.components.reticule.twinstickrange = 15
    inst.components.reticule.ease = true
    inst.components.reticule.ispassableatallpoints = true
    inst.components.reticule.validfn = reticule_valid_fn

    prefab_tuning.apply_light_preset(inst, data_cfg.light_preset)
    set_weapon_light(inst, is_light_enabled())

    inst.entity:SetPristine()
    inst:AddTag("nosteal")
    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("guitar")
    inst.spelltype = "MUSIC"

    if not TheWorld.ismastersim then
        return inst
    end

    local callbacks = {
        on_equip = on_equip,
        on_unequip = on_unequip,
        on_attack = on_attack,
        can_accept_item = can_accept_item,
        on_accept_item = on_accept_item,
        on_inventory_dropped = on_inventory_dropped,
        on_cast_spell = on_cast_spell,
        can_cast_spell = can_cast_spell,
    }

    component_installers.install_common_components(inst, data_cfg, callbacks)
    component_installers.install_combat_components(inst, data_cfg, callbacks)
    component_installers.install_optional_components(inst, data_cfg, callbacks)

    weapon_factory.attach_runtime(inst, oceantrident_def)
    inventory_image_controller.start(inst)

    inst.OnPreLoad = on_pre_load
    inst.OnRemoveEntity = on_remove_entity
    return inst
end

return Prefab("common/inventory/" .. prefab_id, fn, assets, prefabs)

