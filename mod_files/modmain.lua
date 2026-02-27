GLOBAL.setmetatable(env, { __index = function(_t, key) return GLOBAL.rawget(GLOBAL, key) end })

PrefabFiles = {
    "prefab_roseaxe",
    "prefab_rosegunflag",
    "prefab_rosescissors",
    "prefab_roseparasol",
    "prefab_rosefrostwand",
    "prefab_oceantrident",
    "prefab_crowscythe",
    "prefab_naturetoolswand",
    "particle_sakura_rain_all",
}

Assets = {}

local ability_ids = {
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
    "collect",
}

local weapon_config_specs = {
    { weapon_id = "roseaxe" },
    { weapon_id = "rosegunflag" },
    { weapon_id = "rosescissors" },
    { weapon_id = "roseparasol" },
    { weapon_id = "rosefrostwand" },
    { weapon_id = "oceantrident" },
    { weapon_id = "crowscythe" },
    { weapon_id = "naturetoolswand" },
}

local pack_config = {}
for _, config_spec in ipairs(weapon_config_specs) do
    local weapon_id = config_spec.weapon_id
    local weapon_enabled_key = weapon_id .. "_enabled"
    pack_config[weapon_enabled_key] = GetModConfigData(weapon_enabled_key)

    for _, ability_id in ipairs(ability_ids) do
        local ability_enabled_key = string.format("%s_%s_enabled", weapon_id, ability_id)
        pack_config[ability_enabled_key] = GetModConfigData(ability_enabled_key)
    end
end

TUNING.ROSE_EQUIP_PACK_CONFIG = pack_config
TUNING.ROSEAXE_CONFIG = pack_config
TUNING.ROSEGUNFLAG_CONFIG = pack_config
TUNING.ROSESCISSORS_CONFIG = pack_config
TUNING.ROSEPARASOL_CONFIG = pack_config
TUNING.ROSEFROSTWAND_CONFIG = pack_config
TUNING.OCEANTRIDENT_CONFIG = pack_config
TUNING.CROWSCYTHE_CONFIG = pack_config
TUNING.NATURETOOLSWAND_CONFIG = pack_config

TUNING.ROSE_EQUIP_PACK_LANG = GetModConfigData("lang_rose_equip_pack")
TUNING.ROSE_EQUIP_PACK_DIFFICULTY_MODE = GetModConfigData("rose_equip_pack_difficulty_mode") or "newbie"

if TUNING.ROSE_EQUIP_PACK_LANG == "CHS" then
    modimport("scripts/util/rose_equip_strings_cns.lua")
else
    modimport("scripts/util/rose_equip_strings_en.lua")
end

local function setup_roseparasol_useitem_action_text()
    if ACTIONS == nil or ACTIONS.USEITEM == nil or STRINGS == nil or STRINGS.ACTIONS == nil then
        return
    end

    local useitem_strings = STRINGS.ACTIONS.USEITEM
    if type(useitem_strings) ~= "table" then
        STRINGS.ACTIONS.USEITEM = {
            GENERIC = useitem_strings or "Use",
        }
        useitem_strings = STRINGS.ACTIONS.USEITEM
    elseif useitem_strings.GENERIC == nil then
        useitem_strings.GENERIC = "Use"
    end

    if TUNING.ROSE_EQUIP_PACK_LANG == "CHS" then
        useitem_strings.ROSEPARASOL_OPEN = "打开"
        useitem_strings.ROSEPARASOL_CLOSE = "关闭"
        useitem_strings.CROWSCYTHE_OPEN = "打开"
        useitem_strings.CROWSCYTHE_CLOSE = "关闭"
    else
        useitem_strings.ROSEPARASOL_OPEN = "Open"
        useitem_strings.ROSEPARASOL_CLOSE = "Close"
        useitem_strings.CROWSCYTHE_OPEN = "Open"
        useitem_strings.CROWSCYTHE_CLOSE = "Close"
    end

    local old_strfn = ACTIONS.USEITEM.strfn
    ACTIONS.USEITEM.strfn = function(act)
        local invobject = act ~= nil and act.invobject or nil
        if invobject ~= nil and invobject.prefab == "roseparasol" then
            return invobject:HasTag("rose_walk_on_water_enabled") and "ROSEPARASOL_CLOSE" or "ROSEPARASOL_OPEN"
        end

        if invobject ~= nil and invobject.prefab == "crowscythe" then
            return invobject:HasTag("nightvision") and "CROWSCYTHE_CLOSE" or "CROWSCYTHE_OPEN"
        end

        if old_strfn ~= nil then
            return old_strfn(act)
        end
    end
end

setup_roseparasol_useitem_action_text()

modimport("scripts/util/rose_equip_recipes.lua")
