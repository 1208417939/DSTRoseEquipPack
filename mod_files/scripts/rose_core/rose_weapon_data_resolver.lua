local equip_data = require("util/rose_equip_data")
local difficulty_profiles = require("rose_core/rose_difficulty_profiles")
local difficulty_mode = require("rose_core/rose_difficulty_mode")

local resolver = {}

local DEFAULT_DIFFICULTY_MODE = "newbie"

local function shallow_copy_table(input)
    local output = {}
    for key, value in pairs(input) do
        output[key] = value
    end
    return output
end

local function pick_first_non_nil(...)
    local count = select("#", ...)
    for index = 1, count do
        local value = select(index, ...)
        if value ~= nil then
            return value
        end
    end
    return nil
end

local function get_number(value, default_value)
    local number_value = tonumber(value)
    if number_value == nil then
        return default_value
    end
    return number_value
end

local function copy_ingredients(source)
    if type(source) ~= "table" then
        return nil
    end

    local result = {}
    for _, ingredient_data in ipairs(source) do
        if type(ingredient_data) == "table" and ingredient_data[1] ~= nil and ingredient_data[2] ~= nil then
            table.insert(result, { ingredient_data[1], ingredient_data[2] })
        end
    end
    return result
end

local function copy_repair_values(source)
    if type(source) ~= "table" then
        return {}
    end

    local result = {}
    for prefab, uses in pairs(source) do
        if type(prefab) == "string" then
            local repair_uses = tonumber(uses)
            if repair_uses ~= nil and repair_uses > 0 then
                result[prefab] = repair_uses
            end
        end
    end
    return result
end

local function get_active_mode()
    local raw_mode = TUNING ~= nil and TUNING.ROSE_EQUIP_PACK_DIFFICULTY_MODE or nil
    local normalized_mode = difficulty_mode.normalize(raw_mode)
    if normalized_mode ~= nil and difficulty_profiles[normalized_mode] ~= nil then
        return normalized_mode
    end

    return DEFAULT_DIFFICULTY_MODE
end

local function get_profile()
    return difficulty_profiles[get_active_mode()] or difficulty_profiles[DEFAULT_DIFFICULTY_MODE] or {}
end

local function build_equip_data(weapon_data, profile_defaults, weapon_override)
    local defaults = profile_defaults.equip or {}
    local override = weapon_override.equip or {}

    local light_enabled = pick_first_non_nil(override.light_enabled, defaults.light_enabled, true)
    local speed_bonus_enabled = pick_first_non_nil(override.speed_bonus_enabled, defaults.speed_bonus_enabled, true)

    local walk_speed_multiplier = pick_first_non_nil(
        override.walk_speed_multiplier,
        defaults.walk_speed_multiplier,
        weapon_data.walk_speed_multiplier,
        1
    )
    if speed_bonus_enabled == false then
        walk_speed_multiplier = 1
    end

    local dapperness = pick_first_non_nil(override.dapperness, defaults.dapperness, weapon_data.dapperness, 0)

    return {
        light_enabled = light_enabled == true,
        speed_bonus_enabled = speed_bonus_enabled ~= false,
        walk_speed_multiplier = get_number(walk_speed_multiplier, 1),
        dapperness = get_number(dapperness, 0),
    }
end

local function build_combat_data(weapon_data, profile_defaults, weapon_override)
    local defaults = profile_defaults.combat or {}
    local override = weapon_override.combat or {}

    local base_damage = get_number(weapon_data.base_damage, 0)
    if override.base_damage ~= nil then
        base_damage = get_number(override.base_damage, base_damage)
    else
        local base_damage_multiplier = pick_first_non_nil(
            override.base_damage_multiplier,
            defaults.base_damage_multiplier,
            1
        )
        base_damage = base_damage * get_number(base_damage_multiplier, 1)
    end

    local range = pick_first_non_nil(override.range, defaults.range, weapon_data.attack_range, 0)
    local planar_damage = pick_first_non_nil(override.planar_damage, defaults.planar_damage, weapon_data.planar_damage, 0)

    return {
        base_damage = base_damage,
        range = get_number(range, 0),
        planar_damage = get_number(planar_damage, 0),
    }
end

local function build_recipe_data(weapon_data, profile_defaults, weapon_override)
    local defaults = profile_defaults.recipe or {}
    local override = weapon_override.recipe or {}

    local ingredients = copy_ingredients(override.ingredients)
        or copy_ingredients(weapon_override.recipe_ingredients)
        or copy_ingredients(weapon_data.recipe_ingredients)
    local tech = pick_first_non_nil(override.tech, defaults.tech, weapon_data.recipe_tech, TECH.MAGIC_TWO)
    local station_tag = pick_first_non_nil(override.station_tag, defaults.station_tag, weapon_data.recipe_station_tag)
    local nounlock = pick_first_non_nil(override.nounlock, defaults.nounlock, weapon_data.recipe_nounlock)

    return {
        ingredients = ingredients,
        tech = tech,
        station_tag = station_tag,
        nounlock = nounlock == true,
    }
end

local function build_repair_data(weapon_data, profile_defaults, weapon_override)
    local defaults = profile_defaults.repair or {}
    local override = weapon_override.repair or {}
    local source = type(weapon_data.repair) == "table" and weapon_data.repair or {}

    local values = copy_repair_values(
        pick_first_non_nil(
            override.values,
            weapon_override.repair_values,
            defaults.values,
            source.values,
            weapon_data.repair_values
        )
    )

    local has_values = next(values) ~= nil
    local enabled = pick_first_non_nil(override.enabled, defaults.enabled, source.enabled, has_values)

    return {
        enabled = enabled ~= false and has_values,
        values = values,
    }
end

local function resolve_max_uses(weapon_data, profile_defaults, weapon_override)
    local durability_defaults = profile_defaults.durability or {}
    local durability_override = weapon_override.durability or {}

    local max_uses = pick_first_non_nil(
        durability_override.max_uses,
        weapon_override.max_uses,
        durability_defaults.max_uses,
        weapon_data.max_uses
    )

    if max_uses == nil then
        return nil
    end

    local number_value = get_number(max_uses, weapon_data.max_uses or 0)
    if number_value <= 0 then
        return nil
    end
    return math.floor(number_value)
end

local function resolve_profile_data(weapon_id, weapon_data)
    local profile = get_profile()
    local profile_defaults = profile.defaults or {}
    local weapon_override = (profile.weapon_overrides or {})[weapon_id] or {}

    local resolved = shallow_copy_table(weapon_data)

    local equip_cfg = build_equip_data(weapon_data, profile_defaults, weapon_override)
    local combat_cfg = build_combat_data(weapon_data, profile_defaults, weapon_override)
    local recipe_cfg = build_recipe_data(weapon_data, profile_defaults, weapon_override)
    local repair_cfg = build_repair_data(weapon_data, profile_defaults, weapon_override)
    local max_uses = resolve_max_uses(weapon_data, profile_defaults, weapon_override)

    resolved.equip = equip_cfg
    resolved.combat = combat_cfg
    resolved.recipe_data = recipe_cfg
    resolved.repair = repair_cfg
    resolved.repair_values = repair_cfg.values
    if max_uses ~= nil then
        resolved.max_uses = max_uses
    end

    resolved.light_enabled = equip_cfg.light_enabled
    resolved.speed_bonus_enabled = equip_cfg.speed_bonus_enabled
    resolved.walk_speed_multiplier = equip_cfg.walk_speed_multiplier
    resolved.dapperness = equip_cfg.dapperness

    resolved.base_damage = combat_cfg.base_damage
    resolved.attack_range = combat_cfg.range
    resolved.planar_damage = combat_cfg.planar_damage

    resolved.recipe_ingredients = recipe_cfg.ingredients
    resolved.recipe_tech = recipe_cfg.tech
    resolved.recipe_station_tag = recipe_cfg.station_tag
    resolved.recipe_nounlock = recipe_cfg.nounlock

    return resolved
end

---@return string
---@description 返回当前生效的难度档位。
function resolver.get_difficulty_mode()
    return get_active_mode()
end

---@param weapon_id string
---@return table|nil
---@description 解析武器数据并附带当前难度下的配方与战斗/装备参数。
function resolver.resolve_weapon_data(weapon_id)
    local weapon_data = equip_data[weapon_id]
    if weapon_data == nil then
        return nil
    end

    return resolve_profile_data(weapon_id, weapon_data)
end

---@param weapon_id string
---@return table|nil
---@description 仅解析当前难度下的配方信息，供 recipe 注册层调用。
function resolver.resolve_recipe_data(weapon_id)
    local resolved = resolver.resolve_weapon_data(weapon_id)
    if resolved == nil then
        return nil
    end

    local recipe_data = shallow_copy_table(resolved.recipe_data or {})
    recipe_data.prefab_id = resolved.prefab_id or weapon_id
    return recipe_data
end

return resolver
