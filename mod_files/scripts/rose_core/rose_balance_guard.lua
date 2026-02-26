local balance_guard = {}

function balance_guard.ClampMin(value, min_value, default_value)
    if type(value) ~= "number" then
        return default_value
    end

    if value < min_value then
        return min_value
    end

    return value
end

function balance_guard.Clamp01(value, default_value)
    if type(value) ~= "number" then
        return default_value
    end

    if value < 0 then
        return 0
    end

    if value > 1 then
        return 1
    end

    return value
end

return balance_guard
