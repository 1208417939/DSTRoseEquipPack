local LIGHT_PRESET_WARM = {
    falloff = 0.75,
    intensity = 0.8,
    radius = 5.5,
    colour = { 255 / 255, 236 / 255, 173 / 255 },
}

local LIGHT_PRESET_COOL = {
    falloff = 0.75,
    intensity = 0.8,
    radius = 5.5,
    colour = { 168 / 255, 223 / 255, 255 / 255 },
}

local LIGHT_PRESET_PURPLE = {
    falloff = 0.75,
    intensity = 0.8,
    radius = 5.5,
    colour = { 214 / 255, 163 / 255, 255 / 255 },
}

local LIGHT_PRESET_NEUTRAL = {
    falloff = 0.75,
    intensity = 0.8,
    radius = 5.5,
    colour = { 236 / 255, 239 / 255, 236 / 255 },
}

local LIGHT_PRESET_ALIAS_MAP = {
    warm = LIGHT_PRESET_WARM,
    cool = LIGHT_PRESET_COOL,
    purple = LIGHT_PRESET_PURPLE,
    neutral = LIGHT_PRESET_NEUTRAL,
}

local rose_prefab_tuning = {
    DEFAULT_MAX_USES = 350,
    LIGHT_PRESET_WARM = LIGHT_PRESET_WARM,
    LIGHT_PRESET_COOL = LIGHT_PRESET_COOL,
    LIGHT_PRESET_PURPLE = LIGHT_PRESET_PURPLE,
    LIGHT_PRESET_NEUTRAL = LIGHT_PRESET_NEUTRAL,
    INVENTORY_ANIM_DEFAULT = {
        total_frame_count = 96,
        frame_interval = 0.01,
        step_len = 1,
    },
}

local function as_positive_integer(value, default_value)
    local number_value = tonumber(value)
    if number_value == nil or number_value < 1 then
        return default_value
    end
    return math.floor(number_value)
end

local function as_positive_number(value, default_value)
    local number_value = tonumber(value)
    if number_value == nil or number_value <= 0 then
        return default_value
    end
    return number_value
end

local function resolve_light_preset(preset)
    if type(preset) == "string" then
        return LIGHT_PRESET_ALIAS_MAP[string.lower(preset)] or LIGHT_PRESET_WARM
    end

    if type(preset) == "table" then
        return preset
    end

    return LIGHT_PRESET_WARM
end

---@param anim_config table|nil
---@return table
function rose_prefab_tuning.merge_inventory_anim(anim_config)
    local default_config = rose_prefab_tuning.INVENTORY_ANIM_DEFAULT
    local source = anim_config or {}

    return {
        enabled = source.enabled == true,
        atlas_xml_name = source.atlas_xml_name,
        total_frame_count = as_positive_integer(source.total_frame_count, default_config.total_frame_count),
        frame_interval = as_positive_number(source.frame_interval, default_config.frame_interval),
        step_len = as_positive_integer(source.step_len, default_config.step_len),
    }
end

---@param inst ent
---@param preset table|string|nil
function rose_prefab_tuning.apply_light_preset(inst, preset)
    if inst == nil or inst.Light == nil then
        return
    end

    local default_preset = LIGHT_PRESET_WARM
    local source = resolve_light_preset(preset)
    local colour = source.colour or default_preset.colour

    inst.Light:SetFalloff(source.falloff or default_preset.falloff)
    inst.Light:SetIntensity(source.intensity or default_preset.intensity)
    inst.Light:SetRadius(source.radius or default_preset.radius)
    inst.Light:SetColour(colour[1], colour[2], colour[3])
end

return rose_prefab_tuning
