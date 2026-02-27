local rose_prefab_tuning = require("rose_prefab/rose_prefab_tuning")

local component_installers = {}

local function ensure_component(inst, component_name)
    if inst.components[component_name] == nil then
        inst:AddComponent(component_name)
    end
    return inst.components[component_name]
end

local function get_max_uses(data_cfg)
    local value = tonumber(data_cfg.max_uses)
    if value ~= nil and value > 0 then
        return math.floor(value)
    end
    return rose_prefab_tuning.DEFAULT_MAX_USES
end

local function resolve_equip_values(data_cfg)
    local equip_cfg = type(data_cfg.equip) == "table" and data_cfg.equip or {}

    local walk_speed_multiplier = tonumber(equip_cfg.walk_speed_multiplier)
    if walk_speed_multiplier == nil then
        walk_speed_multiplier = tonumber(data_cfg.walk_speed_multiplier)
    end

    local speed_bonus_enabled = equip_cfg.speed_bonus_enabled ~= false
    if speed_bonus_enabled == false then
        walk_speed_multiplier = 1
    elseif walk_speed_multiplier == nil or walk_speed_multiplier <= 0 then
        walk_speed_multiplier = 1
    end

    local dapperness = tonumber(equip_cfg.dapperness)
    if dapperness == nil then
        dapperness = tonumber(data_cfg.dapperness) or 0
    end

    return walk_speed_multiplier, dapperness
end

local function resolve_combat_values(data_cfg)
    local combat_cfg = type(data_cfg.combat) == "table" and data_cfg.combat or {}

    local base_damage = tonumber(combat_cfg.base_damage)
    if base_damage == nil then
        base_damage = tonumber(data_cfg.base_damage) or 0
    end

    local attack_range = tonumber(combat_cfg.range)
    if attack_range == nil then
        attack_range = tonumber(data_cfg.attack_range) or 0
    end

    local planar_damage = tonumber(combat_cfg.planar_damage)
    if planar_damage == nil then
        planar_damage = tonumber(data_cfg.planar_damage) or 0
    end

    return base_damage, attack_range, planar_damage
end

---安装 prefab 通用组件，隔离装备层样板逻辑。
---@param inst ent
---@param data_cfg table
---@param callbacks table|nil
function component_installers.install_common_components(inst, data_cfg, callbacks)
    callbacks = callbacks or {}

    local inspectable = ensure_component(inst, "inspectable")
    if callbacks.inspectable_status ~= nil then
        inspectable.getstatus = callbacks.inspectable_status
    end

    local inventoryitem = ensure_component(inst, "inventoryitem")
    inventoryitem.imagename = data_cfg.prefab_id
    inventoryitem.atlasname = "images/" .. data_cfg.prefab_id .. ".xml"
    if callbacks.on_inventory_dropped ~= nil then
        inventoryitem:SetOnDroppedFn(callbacks.on_inventory_dropped)
    end

    local equippable = ensure_component(inst, "equippable")
    if callbacks.on_equip ~= nil then
        equippable:SetOnEquip(callbacks.on_equip)
    end
    if callbacks.on_unequip ~= nil then
        equippable:SetOnUnequip(callbacks.on_unequip)
    end
    local walk_speed_multiplier, dapperness = resolve_equip_values(data_cfg)
    equippable.walkspeedmult = walk_speed_multiplier
    equippable.dapperness = dapperness

    local trader = ensure_component(inst, "trader")
    if callbacks.can_accept_item ~= nil then
        trader:SetAbleToAcceptTest(callbacks.can_accept_item)
    end
    trader.onaccept = callbacks.on_accept_item
end

---安装武器战斗相关组件（weapon/finiteuses/planardamage）。
---@param inst ent
---@param data_cfg table
---@param callbacks table|nil
function component_installers.install_combat_components(inst, data_cfg, callbacks)
    callbacks = callbacks or {}

    local weapon = ensure_component(inst, "weapon")
    local base_damage, attack_range, planar_damage = resolve_combat_values(data_cfg)
    weapon:SetDamage(base_damage)
    weapon:SetRange(attack_range, attack_range)
    if callbacks.on_attack ~= nil then
        weapon:SetOnAttack(callbacks.on_attack)
    end

    local finiteuses = ensure_component(inst, "finiteuses")
    local max_uses = get_max_uses(data_cfg)
    finiteuses:SetMaxUses(max_uses)
    finiteuses:SetUses(max_uses)
    finiteuses:SetOnFinished(inst.Remove)

    local planardamage = ensure_component(inst, "planardamage")
    planardamage:SetBaseDamage(planar_damage)
end

---按配置安装可选组件，避免 prefab 手写特例分支。
---@param inst ent
---@param data_cfg table
---@param callbacks table|nil
function component_installers.install_optional_components(inst, data_cfg, callbacks)
    callbacks = callbacks or {}

    local tool_actions = data_cfg.tool_actions
    if type(tool_actions) == "table" and #tool_actions > 0 then
        local tool = ensure_component(inst, "tool")
        local finiteuses = inst.components.finiteuses
        for _, action_data in ipairs(tool_actions) do
            local action_id = action_data ~= nil and action_data.action_id or nil
            local action = action_id ~= nil and ACTIONS[action_id] or nil
            if action ~= nil then
                tool:SetAction(action, action_data.effectiveness)

                local use_cost = tonumber(action_data.use_cost)
                if finiteuses ~= nil and use_cost ~= nil and use_cost > 0 then
                    finiteuses:SetConsumption(action, use_cost)
                end
            end
        end
    end

    if type(data_cfg.spell) == "table" then
        local spellcaster = ensure_component(inst, "spellcaster")
        if callbacks.on_cast_spell ~= nil then
            spellcaster:SetSpellFn(callbacks.on_cast_spell)
        end
        if callbacks.can_cast_spell ~= nil then
            spellcaster:SetCanCastFn(callbacks.can_cast_spell)
        end
        spellcaster.canuseonpoint = data_cfg.spell.can_use_on_point == true
        spellcaster.canuseonpoint_water = data_cfg.spell.can_use_on_point_water == true
    end

    if callbacks.on_use_item ~= nil or callbacks.on_stop_use_item ~= nil then
        local useableitem = ensure_component(inst, "useableitem")
        if callbacks.on_use_item ~= nil then
            useableitem:SetOnUseFn(callbacks.on_use_item)
        end
        if callbacks.on_stop_use_item ~= nil then
            useableitem:SetOnStopUseFn(callbacks.on_stop_use_item)
        end
    end

    local insulator_cfg = type(data_cfg.insulator) == "table" and data_cfg.insulator or nil
    if insulator_cfg ~= nil and insulator_cfg.enabled ~= false then
        local insulation = tonumber(insulator_cfg.insulation)
        if insulation ~= nil then
            local insulator = ensure_component(inst, "insulator")
            local mode = type(insulator_cfg.mode) == "string" and string.lower(insulator_cfg.mode) or "summer"
            if mode == "winter" then
                insulator:SetWinter()
            else
                insulator:SetSummer()
            end
            insulator:SetInsulation(insulation)
        end
    end

    if type(data_cfg.talker) == "table" and data_cfg.talker.enabled == true then
        ensure_component(inst, "talker")
    end
end

return component_installers
