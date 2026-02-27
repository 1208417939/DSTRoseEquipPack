local difficulty_mode = {}

local VALID_MODES = {
    newbie = true,
    vanilla = true,
}

local function normalize_string_mode(raw_mode)
    local normalized = string.lower((raw_mode:gsub("^%s+", ""):gsub("%s+$", "")))
    if VALID_MODES[normalized] then
        return normalized
    end

    if normalized == "1" or normalized == "2" or normalized == "true" or normalized == "original" or normalized == "原版" then
        return "vanilla"
    end

    if normalized == "0" or normalized == "false" or normalized == "easy" or normalized == "萌新" then
        return "newbie"
    end

    return nil
end

---@param raw_mode any
---@return string|nil
---@description 将配置项里的难度值归一化为 "newbie"/"vanilla"，兼容历史数值与布尔格式。
function difficulty_mode.normalize(raw_mode)
    local mode_type = type(raw_mode)
    if mode_type == "string" then
        return normalize_string_mode(raw_mode)
    end

    if mode_type == "number" then
        if raw_mode == 1 or raw_mode == 2 then
            return "vanilla"
        end
        if raw_mode == 0 then
            return "newbie"
        end
        return nil
    end

    if mode_type == "boolean" then
        return raw_mode and "vanilla" or "newbie"
    end

    return nil
end

return difficulty_mode
