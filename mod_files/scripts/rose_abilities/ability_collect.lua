local ability = {
    id = "collect",
}

local DEFAULT_COLLECT_RADIUS = 30

---@param value any
---@param default_value number
---@return number
---@description 安全读取数值配置，非 number 时回退默认值。
local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end

    return default_value
end

---@param config table
---@return table<string, boolean>
---@description 兼容数组/字典两种写法，生成排除 prefab 的快速查询表。
local function build_excluded_prefab_map(config)
    local result = {}
    if type(config) ~= "table" or type(config.exclude_prefabs) ~= "table" then
        return result
    end

    local source = config.exclude_prefabs
    local sample_key = next(source)
    if type(sample_key) == "number" then
        for _, prefab_name in ipairs(source) do
            if type(prefab_name) == "string" then
                result[prefab_name] = true
            end
        end
        return result
    end

    for prefab_name, excluded in pairs(source) do
        if excluded == true and type(prefab_name) == "string" then
            result[prefab_name] = true
        end
    end

    return result
end

---@param pos any
---@return number|nil, number|nil, number|nil
---@description 统一解析施法坐标，支持 Vector3 与简易坐标表。
local function resolve_position(pos)
    if pos == nil then
        return nil, nil, nil
    end

    if pos.Get ~= nil then
        return pos:Get()
    end

    return pos.x, pos.y, pos.z
end

---@param target ent
---@param picker ent|nil
---@return boolean
---@description 尝试采摘可采集实体，成功返回 true。
local function try_pick_pickable(target, picker)
    if target == nil or target.components == nil or target.components.pickable == nil then
        return false
    end

    local pickable = target.components.pickable
    if pickable.CanBePicked ~= nil and not pickable:CanBePicked() then
        return false
    end

    return pickable:Pick(picker) == true
end

---@param target ent
---@param harvester ent|nil
---@return boolean
---@description 尝试收获旧版农田作物组件，成功返回 true。
local function try_harvest_crop(target, harvester)
    if target == nil or target.components == nil or target.components.crop == nil then
        return false
    end

    local crop = target.components.crop
    if crop.IsReadyForHarvest ~= nil and not crop:IsReadyForHarvest() then
        return false
    end

    return crop:Harvest(harvester) == true
end

---@param context table
---@param _config table
---@return boolean
---@description 采集法术仅允许在地面坐标施放。
function ability.OnCanCastSpell(context, _config)
    return context ~= nil and context.pos ~= nil and context.doer ~= nil
end

---@param context table
---@param config table
---@description 点施放后在范围内执行采摘与收获，不使用周期轮询。
function ability.OnCastSpell(context, config)
    if context == nil or context.pos == nil then
        return
    end

    local x, y, z = resolve_position(context.pos)
    if x == nil or y == nil or z == nil then
        return
    end

    local doer = context.doer
    if doer == nil and context.inst ~= nil and context.inst.components ~= nil and context.inst.components.inventoryitem ~= nil then
        doer = context.inst.components.inventoryitem.owner
    end
    local crop_harvester = doer
    if crop_harvester ~= nil and (crop_harvester.components == nil or crop_harvester.components.inventory == nil) then
        crop_harvester = nil
    end

    local collect_radius = math.max(0.1, get_number(config.radius, DEFAULT_COLLECT_RADIUS))
    local collect_pickable = config.collect_pickable ~= false
    local collect_crop = config.collect_crop ~= false
    local excluded_prefabs = build_excluded_prefab_map(config)

    local entities = TheSim:FindEntities(x, y, z, collect_radius)
    local total_collected = 0

    for _, target in ipairs(entities) do
        if target ~= nil and not target:HasTag("INLIMBO") then
            local prefab_name = target.prefab
            if prefab_name == nil or excluded_prefabs[prefab_name] ~= true then
                if collect_pickable and try_pick_pickable(target, doer) then
                    total_collected = total_collected + 1
                end

                if collect_crop and try_harvest_crop(target, crop_harvester) then
                    total_collected = total_collected + 1
                end
            end
        end
    end

    context.collect_total = total_collected
end

return ability
