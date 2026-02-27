local weapon_data_resolver = require("rose_core/rose_weapon_data_resolver")
local data_cfg = weapon_data_resolver.resolve_weapon_data("rosefrostwand")
if data_cfg == nil then
    error("Failed to resolve weapon data for rosefrostwand")
end

local weapon_factory = require("rose_core/rose_weapon_factory")
local rose_frostwand_def = require("rose_defs/weapon_def_builder").build("rosefrostwand")
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

    prefab_tuning.apply_light_preset(inst, data_cfg.light_preset)
    set_weapon_light(inst, is_light_enabled())

    inst.entity:SetPristine()
    inst:AddTag("nosteal")

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
    }

    component_installers.install_common_components(inst, data_cfg, callbacks)
    component_installers.install_combat_components(inst, data_cfg, callbacks)
    component_installers.install_optional_components(inst, data_cfg, callbacks)

    weapon_factory.attach_runtime(inst, rose_frostwand_def)
    inventory_image_controller.start(inst)

    inst.OnPreLoad = on_pre_load
    inst.OnRemoveEntity = on_remove_entity
    return inst
end

return Prefab("common/inventory/" .. prefab_id, fn, assets, prefabs)

