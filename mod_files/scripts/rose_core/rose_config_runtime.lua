local config_runtime = {}

local COMPAT_CONFIG_TABLE_KEYS = {
    "ROSEAXE_CONFIG",
    "ROSEGUNFLAG_CONFIG",
    "ROSESCISSORS_CONFIG",
    "ROSEPARASOL_CONFIG",
    "ROSEFROSTWAND_CONFIG",
    "OCEANTRIDENT_CONFIG",
    "CROWSCYTHE_CONFIG",
    "NATURETOOLSWAND_CONFIG",
}

---从指定 TUNING 配置表中读取字段值
---@param table_key string
---@param key string
---@return any|nil
local function read_tuning_table_value(table_key, key)
    if TUNING == nil or TUNING[table_key] == nil then
        return nil
    end

    return TUNING[table_key][key]
end

---按优先级读取 mod 配置（统一配置 > 兼容配置 > GetModConfigData）
---@param key string
---@param default_value any
---@return any
local function read_mod_config(key, default_value)
    local shared_value = read_tuning_table_value("ROSE_EQUIP_PACK_CONFIG", key)
    if shared_value ~= nil then
        return shared_value
    end

    for i = 1, #COMPAT_CONFIG_TABLE_KEYS do
        local compat_value = read_tuning_table_value(COMPAT_CONFIG_TABLE_KEYS[i], key)
        if compat_value ~= nil then
            return compat_value
        end
    end

    if type(GetModConfigData) ~= "function" then
        return default_value
    end

    local ok, value = pcall(GetModConfigData, key)
    if ok and value ~= nil then
        return value
    end

    return default_value
end

local function build_ability_config(prefix, ability_defaults)
    local result = {
        enabled = read_mod_config(prefix .. "_enabled", ability_defaults.enabled ~= false),
    }

    for field_name, default_value in pairs(ability_defaults) do
        if field_name ~= "enabled" then
            local key = string.format("%s_%s", prefix, field_name)
            result[field_name] = read_mod_config(key, default_value)
        end
    end

    return result
end

---将定义层的默认配置与Mod配置环境整合，生成运行时配置
---@param weapon_def table 武器定义表
---@return table # 运行时完整的武器配置
function config_runtime.build_weapon_config(weapon_def)
    local config_key_prefix = weapon_def.config_key_prefix or weapon_def.id
    local result = {
        enabled = read_mod_config(config_key_prefix .. "_enabled", true),
        abilities = {},
    }

    for ability_name, ability_defaults in pairs(weapon_def.ability_defaults or {}) do
        local ability_key_prefix = string.format("%s_%s", config_key_prefix, ability_name)
        result.abilities[ability_name] = build_ability_config(ability_key_prefix, ability_defaults)
    end

    return result
end

return config_runtime
