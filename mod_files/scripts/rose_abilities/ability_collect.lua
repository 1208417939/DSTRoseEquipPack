local ability = {
    id = "collect",
}

local DEFAULT_COLLECT_RADIUS = 30

---@param source table|nil
---@return table<string, boolean>
---@description 将数组/字典形式的字符串集合统一转换为快速查询表。
local function build_string_bool_map(source)
    local result = {}
    if type(source) ~= "table" then
        return result
    end

    local sample_key = next(source)
    if type(sample_key) == "number" then
        for _, name in ipairs(source) do
            if type(name) == "string" then
                result[name] = true
            end
        end
        return result
    end

    for name, enabled in pairs(source) do
        if enabled == true and type(name) == "string" then
            result[name] = true
        end
    end

    return result
end

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
    if type(config) ~= "table" then
        return {}
    end

    return build_string_bool_map(config.exclude_prefabs)
end

---@param config table
---@return table<string, boolean>
---@description 构建禁止采集产物表，用于拦截指定掉落（如 petals / petals_evil）。
local function build_excluded_product_map(config)
    if type(config) ~= "table" then
        return {}
    end

    return build_string_bool_map(config.exclude_product_prefabs)
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

---@param value any
---@return boolean
---@description 轻量判断是否为实体实例，避免把普通 table 当成实体处理。
local function is_entity_instance(value)
    return type(value) == "table" and value.entity ~= nil
end

---@param item ent
---@return number
---@description 读取实体堆叠数量，非可堆叠物默认按 1 计。
local function get_item_count(item)
    if item == nil then
        return 0
    end

    if item.components == nil or item.components.stackable == nil then
        return 1
    end

    local stack_size = item.components.stackable:StackSize()
    if type(stack_size) == "number" and stack_size > 0 then
        return stack_size
    end

    return 1
end

---@param loot any
---@return number
---@description 统计本次收获得到的“物品个数”，用于与耐久消耗一一对应。
local function count_loot_items(loot)
    if loot == nil then
        return 0
    end

    if type(loot) == "string" then
        return 1
    end

    if is_entity_instance(loot) then
        return get_item_count(loot)
    end

    if type(loot) ~= "table" then
        return 0
    end

    local total = 0
    for key, value in pairs(loot) do
        if type(key) == "number" then
            total = total + count_loot_items(value)
        end
    end
    return total
end

---@param target ent
---@param excluded_product_prefabs table<string, boolean>
---@return boolean
---@description 判断 pickable 的产物是否在禁采列表内。
local function is_pickable_product_excluded(target, excluded_product_prefabs)
    if target == nil or target.components == nil or target.components.pickable == nil then
        return false
    end

    local product_prefab = target.components.pickable.product
    return type(product_prefab) == "string" and excluded_product_prefabs[product_prefab] == true
end

---@param target ent
---@param excluded_product_prefabs table<string, boolean>
---@return boolean
---@description 判断 crop 的产物是否在禁采列表内。
local function is_crop_product_excluded(target, excluded_product_prefabs)
    if target == nil or target.components == nil or target.components.crop == nil then
        return false
    end

    local product_prefab = target.components.crop.product_prefab
    return type(product_prefab) == "string" and excluded_product_prefabs[product_prefab] == true
end

---@param inst ent|nil
---@param amount number
---@description 统一消耗法杖耐久，按收获物品总数结算。
local function consume_durability(inst, amount)
    if inst == nil or inst.components == nil or inst.components.finiteuses == nil then
        return
    end

    local use_cost = math.max(0, math.floor(amount))
    if use_cost <= 0 then
        return
    end

    inst.components.finiteuses:Use(use_cost)
end

---@param target ent
---@param picker ent|nil
---@return number
---@description 尝试采摘可采集实体，返回本次实际采到的物品数量。
local function try_pick_pickable(target, picker)
    if target == nil or target.components == nil or target.components.pickable == nil then
        return 0
    end

    local pickable = target.components.pickable
    if pickable.CanBePicked ~= nil and not pickable:CanBePicked() then
        return 0
    end

    local picked, loot = pickable:Pick(picker)
    if picked ~= true then
        return 0
    end

    return count_loot_items(loot)
end

---@param target ent
---@param harvester ent|nil
---@return number
---@description 尝试收获旧版农田作物组件，返回本次实际收获物品数量。
local function try_harvest_crop(target, harvester)
    if target == nil or target.components == nil or target.components.crop == nil then
        return 0
    end

    local crop = target.components.crop
    if crop.IsReadyForHarvest ~= nil and not crop:IsReadyForHarvest() then
        return 0
    end

    local harvested, product = crop:Harvest(harvester)
    if harvested ~= true then
        return 0
    end

    return count_loot_items(product)
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
    local excluded_product_prefabs = build_excluded_product_map(config)

    local entities = TheSim:FindEntities(x, y, z, collect_radius)
    local total_collected = 0

    for _, target in ipairs(entities) do
        if target ~= nil and not target:HasTag("INLIMBO") then
            local prefab_name = target.prefab
            if prefab_name == nil or excluded_prefabs[prefab_name] ~= true then
                if collect_pickable and not is_pickable_product_excluded(target, excluded_product_prefabs) then
                    total_collected = total_collected + try_pick_pickable(target, doer)
                end

                if collect_crop and not is_crop_product_excluded(target, excluded_product_prefabs) then
                    total_collected = total_collected + try_harvest_crop(target, crop_harvester)
                end
            end
        end
    end

    context.collect_total = total_collected
    consume_durability(context.inst, total_collected)
end

return ability
