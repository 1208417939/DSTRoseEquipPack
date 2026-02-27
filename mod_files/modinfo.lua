local cn = locale == "zh" or locale == "zhr"

name = cn and "[DST] 玫瑰武器包" or "[DST] Rose Equip Pack"
version = "1.0.0"

description = [[
Rose Equip Pack
- Rose Axe
- Rose Gun Flag
- Rose Scissors
- Rose Parasol
- Rose Frost Wand
- Ocean Trident
- Crow Scythe
- Nature Tools Wand

Refactored architecture:
definition-driven + runtime ability plugins
]]

author = "Elisa"
forumthread = ""
api_version = 10
api_version_dst = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

---@param title string
---@return table
---@description 生成只读标题配置项。
local function Title(title)
    return {
        name = title,
        hover = "",
        options = { { description = "", data = 0 } },
        default = 0,
    }
end

---@param config_key string
---@param label string
---@param default_value boolean
---@param hover string|nil
---@return table
---@description 生成统一开关项，减少重复配置模板。
local function OnOffOption(config_key, label, default_value, hover)
    return {
        name = config_key,
        label = label,
        hover = hover or "",
        options = {
            { description = "Enabled", data = true },
            { description = "Disabled", data = false },
        },
        default = default_value,
    }
end

---@param config_key string
---@param label string
---@return table
---@description 生成武器语言配置项。
local function LanguageOption(config_key, label)
    return {
        name = config_key,
        label = label,
        hover = "",
        options = {
            { description = "English", data = "EN" },
            { description = "Chinese (Simplified)", data = "CHS" },
        },
        default = cn and "CHS" or "EN",
    }
end

---@param config_key string
---@param label string
---@return table
---@description 生成难度档位配置项（萌新/原版）。
local function DifficultyModeOption(config_key, label)
    return {
        name = config_key,
        label = label,
        hover = cn
            and "萌新：暗影操纵器配方。原版：除黑鸦镰刀/自然法杖外为辉煌铁匠铺；黑鸦镰刀为暗影术基座（以上均不可解锁，仅站旁制作）；自然法杖为完整远古站解锁。"
            or "Newbie: Shadow Manipulator recipes. Vanilla: Most weapons use the Lunar Forge, Crow Scythe uses the Shadow Forge (both nounlock + station-only), and Nature Tools Wand stays Ancient Four unlock.",
        options = {
            { description = cn and "萌新" or "Newbie", data = "newbie" },
            { description = cn and "原版" or "Vanilla", data = "vanilla" },
        },
        default = "newbie",
    }
end

configuration_options = {
    Title("Language"),
    LanguageOption("lang_rose_equip_pack", "Pack Language"),
    Title("Difficulty"),
    DifficultyModeOption("rose_equip_pack_difficulty_mode", "Difficulty Mode"),
    Title("Global Toggles"),
    OnOffOption(
        "rose_equip_pack_repairable_enabled",
        "Repairable Mode (All Weapons)",
        true,
        cn and "开启后武器耐久归零不消失，可用修补材料恢复；归零期间功能完全禁用。"
            or "When enabled, weapons do not disappear at 0 durability and can be repaired; functionality is fully disabled until repaired."
    ),

    Title("Rose Axe Toggles"),
    OnOffOption("roseaxe_enabled", "Weapon Enabled", true, "Master switch for roseaxe runtime abilities."),
    -- OnOffOption("roseaxe_combo_enabled", "Combo", true),
    -- OnOffOption("roseaxe_critical_enabled", "Critical", true),
    -- OnOffOption("roseaxe_behead_enabled", "Behead", false),
    -- OnOffOption("roseaxe_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("roseaxe_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("roseaxe_aoe_enabled", "AOE", false),
    -- OnOffOption("roseaxe_stun_enabled", "Stun", false),
    -- OnOffOption("roseaxe_fire_enabled", "Fire", false),
    -- OnOffOption("roseaxe_ice_enabled", "Ice", false),
    -- OnOffOption("roseaxe_kill_regen_enabled", "Kill Regen", true),
    -- -- OnOffOption("roseaxe_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("roseaxe_tri_circle_enabled", "Tri Circle", true),

    Title("Rose Gun Flag Toggles"),
    OnOffOption("rosegunflag_enabled", "Weapon Enabled", true, "Master switch for rosegunflag runtime abilities."),
    -- OnOffOption("rosegunflag_combo_enabled", "Combo", true),
    -- OnOffOption("rosegunflag_critical_enabled", "Critical", true),
    -- OnOffOption("rosegunflag_behead_enabled", "Behead", false),
    -- OnOffOption("rosegunflag_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("rosegunflag_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("rosegunflag_aoe_enabled", "AOE", false),
    -- OnOffOption("rosegunflag_stun_enabled", "Stun", true),
    -- OnOffOption("rosegunflag_fire_enabled", "Fire", false),
    -- OnOffOption("rosegunflag_ice_enabled", "Ice", false),
    -- OnOffOption("rosegunflag_kill_regen_enabled", "Kill Regen", true),
    -- -- OnOffOption("rosegunflag_upgrade_by_gold_enabled", "Upgrade by Gold", true),
    -- OnOffOption("rosegunflag_tri_circle_enabled", "Tri Circle", false),

    Title("Rose Scissors Toggles"),
    OnOffOption("rosescissors_enabled", "Weapon Enabled", true, "Master switch for rosescissors runtime abilities."),
    -- OnOffOption("rosescissors_combo_enabled", "Combo", true),
    -- OnOffOption("rosescissors_critical_enabled", "Critical", true),
    -- OnOffOption("rosescissors_behead_enabled", "Behead", false),
    -- OnOffOption("rosescissors_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("rosescissors_hamstring_enabled", "Hamstring", true),
    -- OnOffOption("rosescissors_aoe_enabled", "AOE", false),
    -- OnOffOption("rosescissors_stun_enabled", "Stun", false),
    -- OnOffOption("rosescissors_fire_enabled", "Fire", false),
    -- OnOffOption("rosescissors_ice_enabled", "Ice", false),
    -- OnOffOption("rosescissors_kill_regen_enabled", "Kill Regen", true),
    -- -- OnOffOption("rosescissors_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("rosescissors_tri_circle_enabled", "Tri Circle", false),

    Title("Rose Parasol Toggles"),
    OnOffOption("roseparasol_enabled", "Weapon Enabled", true, "Master switch for roseparasol runtime abilities."),
    -- OnOffOption("roseparasol_combo_enabled", "Combo", false),
    -- OnOffOption("roseparasol_critical_enabled", "Critical", true),
    -- OnOffOption("roseparasol_behead_enabled", "Behead", false),
    -- OnOffOption("roseparasol_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("roseparasol_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("roseparasol_aoe_enabled", "AOE", false),
    -- OnOffOption("roseparasol_stun_enabled", "Stun", false),
    -- OnOffOption("roseparasol_fire_enabled", "Fire", false),
    -- OnOffOption("roseparasol_ice_enabled", "Ice", true),
    -- OnOffOption("roseparasol_kill_regen_enabled", "Kill Regen", false),
    -- -- OnOffOption("roseparasol_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("roseparasol_tri_circle_enabled", "Tri Circle", false),
    -- OnOffOption("roseparasol_waterproof_enabled", "Waterproof", true),
    -- OnOffOption("roseparasol_walk_on_water_enabled", "Walk On Water", false, "Enable sea-walking behavior for Rose Parasol."),

    Title("Rose Frost Wand Toggles"),
    OnOffOption("rosefrostwand_enabled", "Weapon Enabled", true, "Master switch for rosefrostwand runtime abilities."),
    -- OnOffOption("rosefrostwand_combo_enabled", "Combo", false),
    -- OnOffOption("rosefrostwand_critical_enabled", "Critical", true),
    -- OnOffOption("rosefrostwand_behead_enabled", "Behead", false),
    -- OnOffOption("rosefrostwand_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("rosefrostwand_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("rosefrostwand_aoe_enabled", "AOE", false),
    -- OnOffOption("rosefrostwand_stun_enabled", "Stun", false),
    -- OnOffOption("rosefrostwand_fire_enabled", "Fire", false),
    -- OnOffOption("rosefrostwand_ice_enabled", "Ice", true),
    -- OnOffOption("rosefrostwand_kill_regen_enabled", "Kill Regen", false),
    -- -- OnOffOption("rosefrostwand_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("rosefrostwand_tri_circle_enabled", "Tri Circle", false),

    Title("Ocean Trident Toggles"),
    OnOffOption("oceantrident_enabled", "Weapon Enabled", true, "Master switch for oceantrident runtime abilities."),
    -- OnOffOption("oceantrident_combo_enabled", "Combo", false),
    -- OnOffOption("oceantrident_critical_enabled", "Critical", true),
    -- OnOffOption("oceantrident_behead_enabled", "Behead", false),
    -- OnOffOption("oceantrident_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("oceantrident_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("oceantrident_aoe_enabled", "AOE", true),
    -- OnOffOption("oceantrident_stun_enabled", "Stun", true),
    -- OnOffOption("oceantrident_fire_enabled", "Fire", false),
    -- OnOffOption("oceantrident_ice_enabled", "Ice", false),
    -- OnOffOption("oceantrident_kill_regen_enabled", "Kill Regen", false),
    -- -- OnOffOption("oceantrident_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("oceantrident_tri_circle_enabled", "Tri Circle", false),
    -- OnOffOption("oceantrident_waterproof_enabled", "Waterproof", true),
    -- OnOffOption("oceantrident_walk_on_water_enabled", "Walk On Water", false, "Enable sea-walking behavior for Ocean Trident."),

    Title("Crow Scythe Toggles"),
    OnOffOption("crowscythe_enabled", "Weapon Enabled", true, "Master switch for crowscythe runtime abilities."),
    -- OnOffOption("crowscythe_combo_enabled", "Combo", true),
    -- OnOffOption("crowscythe_critical_enabled", "Critical", true),
    -- OnOffOption("crowscythe_behead_enabled", "Behead", false),
    -- OnOffOption("crowscythe_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("crowscythe_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("crowscythe_aoe_enabled", "AOE", false),
    -- OnOffOption("crowscythe_stun_enabled", "Stun", false),
    -- OnOffOption("crowscythe_fire_enabled", "Fire", false),
    -- OnOffOption("crowscythe_ice_enabled", "Ice", false),
    -- OnOffOption("crowscythe_kill_regen_enabled", "Kill Regen", false),
    -- -- OnOffOption("crowscythe_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("crowscythe_tri_circle_enabled", "Tri Circle", false),

    Title("Nature Tools Wand Toggles"),
    OnOffOption("naturetoolswand_enabled", "Weapon Enabled", true, "Master switch for naturetoolswand runtime abilities."),
    -- OnOffOption("naturetoolswand_combo_enabled", "Combo", false),
    -- OnOffOption("naturetoolswand_critical_enabled", "Critical", false),
    -- OnOffOption("naturetoolswand_behead_enabled", "Behead", false),
    -- OnOffOption("naturetoolswand_giant_killer_enabled", "Giant Killer", false),
    -- OnOffOption("naturetoolswand_hamstring_enabled", "Hamstring", false),
    -- OnOffOption("naturetoolswand_aoe_enabled", "AOE", false),
    -- OnOffOption("naturetoolswand_stun_enabled", "Stun", false),
    -- OnOffOption("naturetoolswand_fire_enabled", "Fire", false),
    -- OnOffOption("naturetoolswand_ice_enabled", "Ice", false),
    -- OnOffOption("naturetoolswand_kill_regen_enabled", "Kill Regen", false),
    -- -- OnOffOption("naturetoolswand_upgrade_by_gold_enabled", "Upgrade by Gold", false),
    -- OnOffOption("naturetoolswand_tri_circle_enabled", "Tri Circle", false),
    -- OnOffOption("naturetoolswand_collect_enabled", "Collect", true, "Enable point-cast area gathering for Nature Tools Wand."),
}
