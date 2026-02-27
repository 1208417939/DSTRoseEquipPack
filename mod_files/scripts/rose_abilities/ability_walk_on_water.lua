local ability = {
    id = "walk_on_water",
}

local WALK_ON_WATER_TAG = "rose_walk_on_water"
local WALK_ON_WATER_ITEM_ENABLED_TAG = "rose_walk_on_water_enabled"
local STATE_KEY_ENABLED = "enabled"
local OWNER_CACHE_KEY = "walk_on_water_owner"
local DURABILITY_TASK_CACHE_KEY = "walk_on_water_durability_task"
local PREVIOUS_DROWNABLE_ENABLED_KEY = "previous_drownable_enabled"
local WARNED_AT_FIVE_PERCENT_KEY = "warned_at_five_percent"
local WARNED_AT_ONE_PERCENT_KEY = "warned_at_one_percent"
local SECONDS_PER_MINUTE = 60
local TOGGLE_SOUND = "dontstarve/wilson/equip_item"
local ROSEPARASOL_PREFAB = "roseparasol"
local WATER_WARNING_LINE_KEYS = {
    ROSEPARASOL_LOW_DURABILITY_5 = "ROSEPARASOL_LOW_DURABILITY_5",
    ROSEPARASOL_LOW_DURABILITY_1 = "ROSEPARASOL_LOW_DURABILITY_1",
}

---@param owner ent
---@description 按 drownable 状态切换玩家碰撞层，支持海上行走与还原。
local function refresh_owner_collision_mask(owner)
    if owner == nil or owner.Physics == nil or owner.components == nil or owner.components.drownable == nil then
        return
    end

    owner.Physics:ClearCollisionMask()

    if owner.components.drownable.enabled == false then
        owner.Physics:CollidesWith(COLLISION.GROUND)
    elseif not owner:HasTag("playerghost") then
        owner.Physics:CollidesWith(COLLISION.WORLD)
    end

    owner.Physics:CollidesWith(COLLISION.OBSTACLES)
    owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    owner.Physics:CollidesWith(COLLISION.CHARACTERS)
    owner.Physics:CollidesWith(COLLISION.GIANTS)
end

---@param owner ent|nil
---@return boolean
---@description 判断目标是否为可操作的有效实体。
local function is_valid_owner(owner)
    if owner == nil then
        return false
    end

    if owner.IsValid ~= nil and not owner:IsValid() then
        return false
    end

    return true
end

local function is_equipped(inst)
    return inst ~= nil
        and inst.components ~= nil
        and inst.components.equippable ~= nil
        and inst.components.equippable:IsEquipped()
end

local function get_owner(inst, fallback_owner)
    if fallback_owner ~= nil then
        return fallback_owner
    end

    if inst == nil or inst.components == nil or inst.components.inventoryitem == nil then
        return nil
    end

    return inst.components.inventoryitem.owner
end

---@param inst ent|nil
---@param owner ent|nil
---@description 右键切换时播放装备音效，给玩家明确的状态反馈。
local function play_toggle_sound(inst, owner)
    if owner == nil or owner.SoundEmitter == nil then
        return
    end

    local sound = inst ~= nil and inst.skin_equip_sound or nil
    owner.SoundEmitter:PlaySound(sound or TOGGLE_SOUND)
end

---@param runtime component_rose_weapon_runtime
---@return boolean
local function get_enabled_state(runtime)
    local state = runtime:GetAbilityState(ability.id)
    return state[STATE_KEY_ENABLED] == true
end

---@param runtime component_rose_weapon_runtime
---@param enabled boolean
local function set_enabled_state(runtime, enabled)
    local state = runtime:GetAbilityState(ability.id)
    state[STATE_KEY_ENABLED] = enabled == true
end

---@param config table|nil
---@return boolean
local function resolve_default_enabled(config)
    if type(config) == "table" and config.default_enabled ~= nil then
        return config.default_enabled == true
    end

    return true
end

---@param config table|nil
---@return number
local function resolve_durability_cost_per_minute(config)
    if type(config) == "table" and type(config.durability_cost_per_minute) == "number" then
        return math.max(0, config.durability_cost_per_minute)
    end

    return 0
end

local function pick_line(line_data)
    if type(line_data) == "string" and line_data ~= "" then
        return line_data
    end

    if type(line_data) == "table" and #line_data > 0 then
        return line_data[math.random(#line_data)]
    end

    return nil
end

local function get_water_warning_line(line_key)
    if STRINGS == nil or type(STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES) ~= "table" then
        return nil
    end

    return pick_line(STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES[line_key])
end

local function say_owner_line(owner, line)
    if line == nil or owner == nil or owner.components == nil then
        return
    end

    local talker = owner.components.talker
    if talker ~= nil then
        talker:Say(line)
    end
end

local function is_owner_over_water(owner)
    if not is_valid_owner(owner) then
        return false
    end

    if owner.components ~= nil and owner.components.drownable ~= nil and owner.components.drownable.IsOverWater ~= nil then
        return owner.components.drownable:IsOverWater()
    end

    if owner.IsOnOcean ~= nil then
        return owner:IsOnOcean(false)
    end

    return false
end

local function reset_low_durability_warning_state(runtime)
    local state = runtime:GetAbilityState(ability.id)
    state[WARNED_AT_FIVE_PERCENT_KEY] = false
    state[WARNED_AT_ONE_PERCENT_KEY] = false
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@description 仅在海上状态下提示低耐久阈值，避免陆地或非阳伞误报。
local function try_warn_low_durability(runtime, owner)
    local inst = runtime ~= nil and runtime.inst or nil
    if inst == nil or inst.prefab ~= ROSEPARASOL_PREFAB then
        return
    end

    if not is_owner_over_water(owner) then
        return
    end

    if inst.components == nil or inst.components.finiteuses == nil then
        return
    end

    local percent = inst.components.finiteuses:GetPercent()
    if type(percent) ~= "number" then
        return
    end

    local state = runtime:GetAbilityState(ability.id)
    if percent <= 0.01 then
        if state[WARNED_AT_ONE_PERCENT_KEY] ~= true then
            say_owner_line(owner, get_water_warning_line(WATER_WARNING_LINE_KEYS.ROSEPARASOL_LOW_DURABILITY_1))
            state[WARNED_AT_ONE_PERCENT_KEY] = true
        end
        return
    end

    if percent <= 0.05 and state[WARNED_AT_FIVE_PERCENT_KEY] ~= true then
        say_owner_line(owner, get_water_warning_line(WATER_WARNING_LINE_KEYS.ROSEPARASOL_LOW_DURABILITY_5))
        state[WARNED_AT_FIVE_PERCENT_KEY] = true
    end
end

---@param runtime component_rose_weapon_runtime
local function stop_durability_task(runtime)
    local task = runtime.cache[DURABILITY_TASK_CACHE_KEY]
    if task ~= nil and task.Cancel ~= nil then
        task:Cancel()
    end
    runtime.cache[DURABILITY_TASK_CACHE_KEY] = nil
end

---@param owner ent|nil
---@description 当持有者重新允许溺水后，立即触发一次海上落水判定，避免“站海不落水”。
local function force_drown_check(owner)
    if owner == nil or owner.components == nil then
        return
    end

    local drownable = owner.components.drownable
    if drownable == nil or drownable.enabled ~= true or drownable.CheckDrownable == nil then
        return
    end

    drownable:CheckDrownable()
end

---@param runtime component_rose_weapon_runtime
---@description 踏水开启时周期性消耗耐久。
local function consume_durability(runtime)
    local inst = runtime ~= nil and runtime.inst or nil
    if inst == nil or (inst.IsValid ~= nil and not inst:IsValid()) then
        stop_durability_task(runtime)
        return
    end

    if not is_equipped(inst) or not get_enabled_state(runtime) then
        stop_durability_task(runtime)
        return
    end

    if inst.components == nil or inst.components.finiteuses == nil then
        stop_durability_task(runtime)
        return
    end

    inst.components.finiteuses:Use(1)
    local owner = get_owner(inst)
    try_warn_low_durability(runtime, owner)

    if inst.components.finiteuses:GetUses() <= 0 then
        stop_durability_task(runtime)
    end
end

---@param runtime component_rose_weapon_runtime
---@param config table|nil
local function start_durability_task(runtime, config)
    stop_durability_task(runtime)

    local durability_cost_per_minute = resolve_durability_cost_per_minute(config)
    if durability_cost_per_minute <= 0 then
        return
    end

    if runtime.inst == nil then
        return
    end

    local interval = SECONDS_PER_MINUTE / durability_cost_per_minute
    if interval <= 0 then
        return
    end

    runtime.cache[DURABILITY_TASK_CACHE_KEY] = runtime.inst:DoPeriodicTask(interval, function()
        consume_durability(runtime)
    end)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent
---@param config table|nil
---@description 应用踏水状态：关闭 drownable 并切换碰撞层。
local function apply_walk_on_water(runtime, owner, config)
    if not is_valid_owner(owner) then
        return
    end

    if runtime ~= nil and runtime.inst ~= nil then
        runtime.inst:AddTag(WALK_ON_WATER_ITEM_ENABLED_TAG)
    end

    owner:AddTag(WALK_ON_WATER_TAG)
    runtime.cache[OWNER_CACHE_KEY] = owner

    if owner.components == nil or owner.components.drownable == nil then
        set_enabled_state(runtime, true)
        start_durability_task(runtime, config)
        return
    end

    local state = runtime:GetAbilityState(ability.id)
    state[PREVIOUS_DROWNABLE_ENABLED_KEY] = owner.components.drownable.enabled ~= false
    owner.components.drownable.enabled = false
    refresh_owner_collision_mask(owner)
    set_enabled_state(runtime, true)
    start_durability_task(runtime, config)
    try_warn_low_durability(runtime, owner)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param should_force_drown boolean|nil
---@description 还原踏水状态：恢复 drownable 与碰撞层。
local function clear_walk_on_water(runtime, owner, should_force_drown)
    local target_owner = owner or runtime.cache[OWNER_CACHE_KEY]
    local was_enabled = get_enabled_state(runtime)
    stop_durability_task(runtime)
    if runtime ~= nil and runtime.inst ~= nil then
        runtime.inst:RemoveTag(WALK_ON_WATER_ITEM_ENABLED_TAG)
    end

    if not is_valid_owner(target_owner) then
        runtime.cache[OWNER_CACHE_KEY] = nil
        set_enabled_state(runtime, false)
        return
    end

    local had_walk_on_water_tag = target_owner:HasTag(WALK_ON_WATER_TAG)
    target_owner:RemoveTag(WALK_ON_WATER_TAG)

    if target_owner.components ~= nil and target_owner.components.drownable ~= nil then
        local state = runtime:GetAbilityState(ability.id)
        local previous_enabled = state[PREVIOUS_DROWNABLE_ENABLED_KEY]
        local should_restore = type(previous_enabled) == "boolean" or was_enabled or had_walk_on_water_tag
        if should_restore then
            target_owner.components.drownable.enabled = type(previous_enabled) == "boolean" and previous_enabled or true
        end
        state[PREVIOUS_DROWNABLE_ENABLED_KEY] = nil
        if should_restore then
            refresh_owner_collision_mask(target_owner)
        end
        if should_restore and should_force_drown ~= false then
            force_drown_check(target_owner)
        end
    end

    runtime.cache[OWNER_CACHE_KEY] = nil
    set_enabled_state(runtime, false)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent
---@param config table
---@description 装备时根据配置决定默认开关状态；玫瑰阳伞默认关闭。
function ability.OnEquip(runtime, owner, config)
    reset_low_durability_warning_state(runtime)

    local current_owner = get_owner(runtime.inst, owner)
    local previous_owner = runtime.cache[OWNER_CACHE_KEY]

    if previous_owner ~= nil and previous_owner ~= current_owner then
        clear_walk_on_water(runtime, previous_owner, false)
    end

    if resolve_default_enabled(config) then
        apply_walk_on_water(runtime, current_owner, config)
        return
    end

    clear_walk_on_water(runtime, current_owner)
end

---@param context table
---@param config table|nil
---@description 右键切换踏水开关：开启时可海上行走，关闭时恢复溺水检测。
function ability.OnUseItem(context, config)
    if context == nil or context.runtime == nil then
        return
    end

    local runtime = context.runtime
    local inst = context.inst or runtime.inst
    if not is_equipped(inst) then
        return
    end

    local owner = get_owner(inst, context.doer)
    if owner == nil then
        return
    end

    if get_enabled_state(runtime) then
        clear_walk_on_water(runtime, owner)
    else
        apply_walk_on_water(runtime, owner, config)
    end

    play_toggle_sound(inst, owner)
    context.handled = true
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param _config table
---@description 卸下时关闭踏水能力。
function ability.OnUnequip(runtime, owner, _config)
    clear_walk_on_water(runtime, owner)
end

---@param runtime component_rose_weapon_runtime
---@param _config table
---@description 组件移除时兜底清理踏水状态。
function ability.OnRemove(runtime, _config)
    clear_walk_on_water(runtime, nil, false)
end

return ability
