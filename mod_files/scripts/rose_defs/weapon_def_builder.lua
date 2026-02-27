local weapon_data_resolver = require("rose_core/rose_weapon_data_resolver")

local function shallow_copy_table(input)
    local output = {}
    for key, value in pairs(input) do
        output[key] = value
    end
    return output
end

local global_ability_order = {
    "combo",
    "critical",
    "behead",
    "giant_killer",
    "hamstring",
    "aoe",
    "stun",
    "fire",
    "ice",
    "kill_regen",
    "upgrade_by_gold",
    "tri_circle",
    "waterproof",
    "walk_on_water",
    "fish_burst",
    "nightvision_toggle",
    "collect",
}

local function build_ability_defaults_by_order(data, ordered_ability_ids)
    local defaults = {}

    for i = 1, #ordered_ability_ids do
        local ability_id = ordered_ability_ids[i]
        local source = data.abilities ~= nil and data.abilities[ability_id] or nil
        if source ~= nil then
            defaults[ability_id] = shallow_copy_table(source)
        else
            defaults[ability_id] = { enabled = false }
        end
    end

    return defaults
end

local function copy_repair_values(source)
    if type(source) ~= "table" then
        return {}
    end

    local result = {}
    for prefab, uses in pairs(source) do
        local repair_uses = tonumber(uses)
        if type(prefab) == "string" and repair_uses ~= nil and repair_uses > 0 then
            result[prefab] = repair_uses
        end
    end
    return result
end

local builder = {}

---@param weapon_key string The key in rose_equip_data (e.g., "roseaxe", "oceantrident")
---@return table RoseWeaponDef
function builder.build(weapon_key)
    local weapon_data = weapon_data_resolver.resolve_weapon_data(weapon_key)
    if weapon_data == nil then
        error("Weapon data not found for key: " .. tostring(weapon_key))
    end

    local equip_cfg = weapon_data.equip or {}
    local combat_cfg = weapon_data.combat or {}
    local recipe_cfg = weapon_data.recipe_data or {}
    local repair_cfg = weapon_data.repair or {}

    local ability_modules = {}
    for _, ability_id in ipairs(global_ability_order) do
        ability_modules[ability_id] = "rose_abilities/ability_" .. ability_id
    end

    local result = {
        id = weapon_data.prefab_id,
        config_key_prefix = weapon_data.prefab_id,
        ability_defaults = build_ability_defaults_by_order(weapon_data, global_ability_order),
        ability_order = global_ability_order,
        ability_modules = ability_modules,
        equip = {
            walk_speed_multiplier = equip_cfg.walk_speed_multiplier or weapon_data.walk_speed_multiplier,
            dapperness = equip_cfg.dapperness or weapon_data.dapperness,
            light_enabled = equip_cfg.light_enabled,
            speed_bonus_enabled = equip_cfg.speed_bonus_enabled,
        },
        combat = {
            base_damage = combat_cfg.base_damage or weapon_data.base_damage,
            range = combat_cfg.range or weapon_data.attack_range,
            planar_damage = combat_cfg.planar_damage or weapon_data.planar_damage,
        },
        progression = {
            growth_curve = {
                exponent = 1.2,
                scale = 10,
                precision = 0.1,
            },
        },
        recipe = recipe_cfg.ingredients or weapon_data.recipe_ingredients,
        repair = {
            enabled = repair_cfg.enabled == true,
            values = copy_repair_values(repair_cfg.values or weapon_data.repair_values),
        },
    }

    return result
end

return builder
