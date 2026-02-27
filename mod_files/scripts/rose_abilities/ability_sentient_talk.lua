local ability = {
    id = "sentient_talk",
}

local EVENT_NIGHTVISION_TOGGLED = "rose_sentient_nightvision_toggled"
local EVENT_KILL_REGEN = "rose_sentient_kill_regen"

local TALK_POOL_DUSK_NIGHT = "DUSK_NIGHT"
local TALK_POOL_GROUND = "GROUND"
local TALK_POOL_FULLMOON = "FULLMOON"
local TALK_POOL_NEWMOON = "NEWMOON"
local TALK_POOL_NIGHTVISION_ON = "NIGHTVISION_ON"
local TALK_POOL_NIGHTVISION_OFF = "NIGHTVISION_OFF"
local TALK_POOL_KILL_REGEN = "KILL_REGEN"
local TALK_POOL_REJECT = "REJECT"

local CACHE_KEYS = {
    random_task = "sentient_talk_random_task",
    kill_task = "sentient_talk_kill_task",
    owner_ref = "sentient_talk_owner_ref",

    on_built = "sentient_talk_on_built",
    on_put_in_inventory = "sentient_talk_on_put_in_inventory",
    on_dropped = "sentient_talk_on_dropped",
    on_equipped = "sentient_talk_on_equipped",
    on_unequipped = "sentient_talk_on_unequipped",
    on_nightvision_toggled = "sentient_talk_on_nightvision_toggled",
    on_kill_regen = "sentient_talk_on_kill_regen",

    watch_isdusk = "sentient_talk_watch_isdusk",
    watch_isnight = "sentient_talk_watch_isnight",
    watch_isnewmoon = "sentient_talk_watch_isnewmoon",
    watch_isfullmoon = "sentient_talk_watch_isfullmoon",
}

local STATE_KEYS = {
    chatter_heat = "chatter_heat",
    last_talk_time = "last_talk_time",
    last_heat_update_time = "last_heat_update_time",
    recent_line_ids = "recent_line_ids",
    bound_userid = "bound_userid",
    last_reject_time = "last_reject_time",
    pending_kill_talk_count = "pending_kill_talk_count",
}

local DEFAULT_DUSK_CHANCE = 0.18
local DEFAULT_NIGHT_CHANCE = 0.30
local DEFAULT_NIGHTVISION_BONUS = 0.15
local DEFAULT_HEAT_BONUS_MULTIPLIER = 0.25
local DEFAULT_JITTER_RANGE = 0.08
local DEFAULT_MIN_PROBABILITY = 0.05
local DEFAULT_MAX_PROBABILITY = 0.90

local DEFAULT_HARD_COOLDOWN = 6
local DEFAULT_FORCE_MIN_INTERVAL = 1
local DEFAULT_NORMAL_MIN_INTERVAL = 25
local DEFAULT_NORMAL_MAX_INTERVAL = 50
local DEFAULT_HOT_MIN_INTERVAL = 12
local DEFAULT_HOT_MAX_INTERVAL = 28
local DEFAULT_HOT_THRESHOLD = 0.35
local DEFAULT_RECENT_MEMORY_SIZE = 4

local DEFAULT_HEAT_DECAY_PER_SECOND = 0.015
local DEFAULT_NIGHTVISION_HEAT_GAIN = 0.35
local DEFAULT_NIGHTVISION_HEAT_GAIN_OFF = 0.10
local DEFAULT_KILL_HEAT_GAIN = 0.25
local DEFAULT_KILL_HEAT_SCALE = 0.01
local DEFAULT_KILL_HEAT_CAP = 0.35
local DEFAULT_KILL_TALK_CHANCE = 0.45
local DEFAULT_KILL_TALK_DELAY_MIN = 0.20
local DEFAULT_KILL_TALK_DELAY_MAX = 0.60
local DEFAULT_REJECT_COOLDOWN = 2.5
local DEFAULT_GROUND_EVENT_CHANCE = 0.35
local DEFAULT_IDLE_GROUND_CHANCE = 0.18
local NEGATIVE_TIME_SENTINEL = -1000000

local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

local function clamp(value, min_value, max_value)
    if value < min_value then
        return min_value
    end
    if value > max_value then
        return max_value
    end
    return value
end

local function is_table_array(value)
    return type(value) == "table" and type(value[1]) == "string"
end

local function get_talk_pool(pool_key)
    local root = STRINGS ~= nil and STRINGS.CROWSCYTHE_TALK or nil
    local pool = root ~= nil and root[pool_key] or nil
    if is_table_array(pool) then
        return pool
    end
    return nil
end

local function get_grand_owner(inst)
    if inst == nil or inst.components == nil or inst.components.inventoryitem == nil then
        return nil
    end
    return inst.components.inventoryitem:GetGrandOwner()
end

local function get_world_flags()
    local world_state = TheWorld ~= nil and TheWorld.state or nil
    return {
        is_dusk = world_state ~= nil and world_state.isdusk == true,
        is_night = world_state ~= nil and world_state.isnight == true,
        is_new_moon = world_state ~= nil and world_state.isnewmoon == true,
        is_full_moon = world_state ~= nil and world_state.isfullmoon == true,
    }
end

local function is_runtime_active(runtime, config)
    if runtime == nil or runtime.inst == nil then
        return false
    end

    if type(config) == "table" and config.enabled == false then
        return false
    end

    if runtime.IsEnabled ~= nil and not runtime:IsEnabled() then
        return false
    end

    return true
end

local function get_state(runtime)
    return runtime:GetAbilityState(ability.id)
end

local function ensure_state_defaults(runtime)
    local state = get_state(runtime)

    if type(state[STATE_KEYS.chatter_heat]) ~= "number" then
        state[STATE_KEYS.chatter_heat] = 0
    end

    if type(state[STATE_KEYS.last_talk_time]) ~= "number" then
        state[STATE_KEYS.last_talk_time] = NEGATIVE_TIME_SENTINEL
    end

    if type(state[STATE_KEYS.last_heat_update_time]) ~= "number" then
        state[STATE_KEYS.last_heat_update_time] = GetTime()
    end

    if type(state[STATE_KEYS.recent_line_ids]) ~= "table" then
        state[STATE_KEYS.recent_line_ids] = {}
    end

    if type(state[STATE_KEYS.last_reject_time]) ~= "number" then
        state[STATE_KEYS.last_reject_time] = NEGATIVE_TIME_SENTINEL
    end

    if type(state[STATE_KEYS.pending_kill_talk_count]) ~= "number" then
        state[STATE_KEYS.pending_kill_talk_count] = 0
    end

    return state
end

local function cancel_cache_task(runtime, cache_key)
    local task = runtime.cache[cache_key]
    if task ~= nil and task.Cancel ~= nil then
        task:Cancel()
    end
    runtime.cache[cache_key] = nil
end

local function update_chatter_heat(runtime, config)
    local state = ensure_state_defaults(runtime)
    local now = GetTime()
    local last_time = get_number(state[STATE_KEYS.last_heat_update_time], now)
    local elapsed = math.max(0, now - last_time)

    local decay_per_second = math.max(0, get_number(config.heat_decay_per_second, DEFAULT_HEAT_DECAY_PER_SECOND))
    local old_heat = get_number(state[STATE_KEYS.chatter_heat], 0)
    state[STATE_KEYS.chatter_heat] = clamp(old_heat - elapsed * decay_per_second, 0, 1)
    state[STATE_KEYS.last_heat_update_time] = now
end

local function add_chatter_heat(runtime, amount)
    local state = ensure_state_defaults(runtime)
    local current_heat = get_number(state[STATE_KEYS.chatter_heat], 0)
    state[STATE_KEYS.chatter_heat] = clamp(current_heat + math.max(0, amount or 0), 0, 1)
    state[STATE_KEYS.last_heat_update_time] = GetTime()
end

local function resolve_recent_memory_size(config)
    return math.max(1, math.floor(get_number(config.recent_memory_size, DEFAULT_RECENT_MEMORY_SIZE)))
end

local function resolve_reject_cooldown(config)
    return math.max(0, get_number(config.reject_cooldown, DEFAULT_REJECT_COOLDOWN))
end

local function resolve_hard_cooldown(config)
    return math.max(0, get_number(config.hard_cooldown, DEFAULT_HARD_COOLDOWN))
end

local function resolve_force_min_interval(config)
    return math.max(0, get_number(config.force_min_interval, DEFAULT_FORCE_MIN_INTERVAL))
end

local function can_talk_now(runtime, config, force)
    local state = ensure_state_defaults(runtime)
    local now = GetTime()
    local last_talk_time = get_number(state[STATE_KEYS.last_talk_time], NEGATIVE_TIME_SENTINEL)

    if force then
        return now - last_talk_time >= resolve_force_min_interval(config)
    end

    return now - last_talk_time >= resolve_hard_cooldown(config)
end

local function build_recent_lookup(recent_line_ids)
    local lookup = {}
    for i = 1, #recent_line_ids do
        lookup[recent_line_ids[i]] = true
    end
    return lookup
end

local function select_line_token(pool_key, lines, state, recent_limit)
    local recent_line_ids = state[STATE_KEYS.recent_line_ids]
    local recent_lookup = build_recent_lookup(recent_line_ids)
    local candidates = {}

    for i = 1, #lines do
        local token = pool_key .. ":" .. tostring(i)
        if recent_lookup[token] ~= true then
            table.insert(candidates, i)
        end
    end

    local picked_index
    if #candidates > 0 then
        picked_index = candidates[math.random(#candidates)]
    else
        picked_index = math.random(#lines)
    end

    local token = pool_key .. ":" .. tostring(picked_index)
    table.insert(recent_line_ids, token)
    while #recent_line_ids > recent_limit do
        table.remove(recent_line_ids, 1)
    end

    return lines[picked_index]
end

local function talk_from_pool(runtime, pool_key, config, force)
    if not is_runtime_active(runtime, config) then
        return false
    end

    if runtime.IsDurabilityBroken ~= nil and runtime:IsDurabilityBroken() then
        return false
    end

    local lines = get_talk_pool(pool_key)
    if lines == nil then
        return false
    end

    if not can_talk_now(runtime, config, force == true) then
        return false
    end

    local inst = runtime.inst
    local talker = inst.components ~= nil and inst.components.talker or nil
    if talker == nil then
        return false
    end

    local state = ensure_state_defaults(runtime)
    local line = select_line_token(pool_key, lines, state, resolve_recent_memory_size(config))
    if type(line) ~= "string" or line == "" then
        return false
    end

    talker:Say(line)
    state[STATE_KEYS.last_talk_time] = GetTime()
    return true
end

local function resolve_talk_probability(runtime, config, world_flags)
    local base_chance = 0
    if world_flags.is_night then
        base_chance = get_number(config.night_chance, DEFAULT_NIGHT_CHANCE)
    elseif world_flags.is_dusk then
        base_chance = get_number(config.dusk_chance, DEFAULT_DUSK_CHANCE)
    end

    local state = ensure_state_defaults(runtime)
    local chatter_heat = clamp(get_number(state[STATE_KEYS.chatter_heat], 0), 0, 1)
    local heat_bonus = chatter_heat * get_number(config.heat_bonus_multiplier, DEFAULT_HEAT_BONUS_MULTIPLIER)
    local nightvision_bonus = runtime.inst:HasTag("nightvision")
            and get_number(config.nightvision_bonus, DEFAULT_NIGHTVISION_BONUS)
        or 0

    local jitter_range = math.max(0, get_number(config.jitter_range, DEFAULT_JITTER_RANGE))
    local jitter = (math.random() * 2 - 1) * jitter_range

    local min_probability = get_number(config.min_probability, DEFAULT_MIN_PROBABILITY)
    local max_probability = get_number(config.max_probability, DEFAULT_MAX_PROBABILITY)
    return clamp(base_chance + heat_bonus + nightvision_bonus + jitter, min_probability, max_probability)
end

local function try_night_or_dusk_talk(runtime, config, force_moon_lines)
    local world_flags = get_world_flags()
    if world_flags.is_new_moon and world_flags.is_night then
        return talk_from_pool(runtime, TALK_POOL_NEWMOON, config, force_moon_lines == true)
    end

    if world_flags.is_full_moon and world_flags.is_night then
        return talk_from_pool(runtime, TALK_POOL_FULLMOON, config, force_moon_lines == true)
    end

    if world_flags.is_dusk or world_flags.is_night then
        local chance = resolve_talk_probability(runtime, config, world_flags)
        if math.random() <= chance then
            return talk_from_pool(runtime, TALK_POOL_DUSK_NIGHT, config, false)
        end
    end

    return false
end

local function resolve_random_interval(runtime, config)
    update_chatter_heat(runtime, config)

    local state = ensure_state_defaults(runtime)
    local chatter_heat = clamp(get_number(state[STATE_KEYS.chatter_heat], 0), 0, 1)
    local hot_threshold = clamp(get_number(config.hot_threshold, DEFAULT_HOT_THRESHOLD), 0, 1)
    local is_hot = runtime.inst:HasTag("nightvision") or chatter_heat >= hot_threshold

    local min_interval = is_hot
            and get_number(config.hot_min_interval, DEFAULT_HOT_MIN_INTERVAL)
        or get_number(config.normal_min_interval, DEFAULT_NORMAL_MIN_INTERVAL)
    local max_interval = is_hot
            and get_number(config.hot_max_interval, DEFAULT_HOT_MAX_INTERVAL)
        or get_number(config.normal_max_interval, DEFAULT_NORMAL_MAX_INTERVAL)

    min_interval = math.max(1, min_interval)
    max_interval = math.max(min_interval, max_interval)
    return min_interval + math.random() * (max_interval - min_interval)
end

local function run_random_talk(runtime, config)
    if not is_runtime_active(runtime, config) then
        return
    end

    update_chatter_heat(runtime, config)
    if try_night_or_dusk_talk(runtime, config, true) then
        return
    end

    local idle_ground_chance = clamp(get_number(config.idle_ground_chance, DEFAULT_IDLE_GROUND_CHANCE), 0, 1)
    if get_grand_owner(runtime.inst) == nil and math.random() <= idle_ground_chance then
        talk_from_pool(runtime, TALK_POOL_GROUND, config, false)
    end
end

local function schedule_random_talk(runtime, config, delay)
    cancel_cache_task(runtime, CACHE_KEYS.random_task)

    if runtime == nil or runtime.inst == nil then
        return
    end

    if type(config) == "table" and config.enabled == false then
        return
    end

    if runtime.IsEnabled ~= nil and not runtime:IsEnabled() then
        return
    end

    if runtime.IsDurabilityBroken ~= nil and runtime:IsDurabilityBroken() then
        return
    end

    local talk_delay = delay
    if type(talk_delay) ~= "number" then
        talk_delay = resolve_random_interval(runtime, config)
    end
    talk_delay = math.max(1, talk_delay)

    runtime.cache[CACHE_KEYS.random_task] = runtime.inst:DoTaskInTime(talk_delay, function()
        runtime.cache[CACHE_KEYS.random_task] = nil
        run_random_talk(runtime, config)
        schedule_random_talk(runtime, config)
    end)
end

local function set_bound_userid(runtime, userid)
    if type(userid) ~= "string" or userid == "" then
        return
    end
    local state = ensure_state_defaults(runtime)
    state[STATE_KEYS.bound_userid] = userid
end

local function get_bound_userid(runtime)
    local state = ensure_state_defaults(runtime)
    local userid = state[STATE_KEYS.bound_userid]
    if type(userid) == "string" and userid ~= "" then
        return userid
    end
    return nil
end

local function enforce_bound_owner(runtime, owner_hint, config)
    if not is_runtime_active(runtime, config) then
        return
    end

    local inst = runtime.inst
    local owner = get_grand_owner(inst) or owner_hint
    runtime.cache[CACHE_KEYS.owner_ref] = owner

    if owner == nil then
        return
    end

    local owner_userid = owner.userid
    if type(owner_userid) ~= "string" or owner_userid == "" then
        return
    end

    local bound_userid = get_bound_userid(runtime)
    if bound_userid == nil then
        set_bound_userid(runtime, owner_userid)
        return
    end

    if bound_userid == owner_userid then
        return
    end

    if owner.components == nil or owner.components.inventory == nil then
        return
    end

    owner.components.inventory:DropItem(inst, true, true)

    local state = ensure_state_defaults(runtime)
    local now = GetTime()
    local last_reject_time = get_number(state[STATE_KEYS.last_reject_time], NEGATIVE_TIME_SENTINEL)
    if now - last_reject_time < resolve_reject_cooldown(config) then
        return
    end

    state[STATE_KEYS.last_reject_time] = now
    talk_from_pool(runtime, TALK_POOL_REJECT, config, true)
end

local function on_worldstate_dusk(runtime, is_dusk, config)
    if is_dusk ~= true then
        return
    end

    if not is_runtime_active(runtime, config) then
        return
    end

    update_chatter_heat(runtime, config)
    try_night_or_dusk_talk(runtime, config, true)

    local ground_event_chance = clamp(get_number(config.ground_event_chance, DEFAULT_GROUND_EVENT_CHANCE), 0, 1)
    if get_grand_owner(runtime.inst) == nil and math.random() <= ground_event_chance then
        talk_from_pool(runtime, TALK_POOL_GROUND, config, false)
    end

    schedule_random_talk(runtime, config)
end

local function on_worldstate_night(runtime, is_night, config)
    if is_night ~= true then
        return
    end

    if not is_runtime_active(runtime, config) then
        return
    end

    update_chatter_heat(runtime, config)
    try_night_or_dusk_talk(runtime, config, true)
    schedule_random_talk(runtime, config)
end

local function on_worldstate_newmoon(runtime, is_new_moon, config)
    if is_new_moon ~= true then
        return
    end

    if not is_runtime_active(runtime, config) then
        return
    end

    talk_from_pool(runtime, TALK_POOL_NEWMOON, config, true)
    schedule_random_talk(runtime, config)
end

local function on_worldstate_fullmoon(runtime, is_full_moon, config)
    if is_full_moon ~= true then
        return
    end

    if not is_runtime_active(runtime, config) then
        return
    end

    talk_from_pool(runtime, TALK_POOL_FULLMOON, config, true)
    schedule_random_talk(runtime, config)
end

local function on_nightvision_toggled(runtime, data, config)
    if not is_runtime_active(runtime, config) then
        return
    end

    local enabled = data ~= nil and data.enabled == true
    local heat_gain = enabled
            and get_number(config.nightvision_heat_gain, DEFAULT_NIGHTVISION_HEAT_GAIN)
        or get_number(config.nightvision_heat_gain_off, DEFAULT_NIGHTVISION_HEAT_GAIN_OFF)
    add_chatter_heat(runtime, heat_gain)

    talk_from_pool(runtime, enabled and TALK_POOL_NIGHTVISION_ON or TALK_POOL_NIGHTVISION_OFF, config, true)
    schedule_random_talk(runtime, config)
end

local function on_kill_regen(runtime, data, config)
    if not is_runtime_active(runtime, config) then
        return
    end

    local state = ensure_state_defaults(runtime)
    local heal_amount = math.max(0, get_number(data ~= nil and data.heal or nil, 0))
    local heat_gain = get_number(config.kill_heat_gain, DEFAULT_KILL_HEAT_GAIN)
    local heat_scale = math.max(0, get_number(config.kill_heat_scale, DEFAULT_KILL_HEAT_SCALE))
    local heat_cap = math.max(0, get_number(config.kill_heat_cap, DEFAULT_KILL_HEAT_CAP))
    add_chatter_heat(runtime, heat_gain + math.min(heat_cap, heal_amount * heat_scale))
    state[STATE_KEYS.pending_kill_talk_count] = math.min(6, get_number(state[STATE_KEYS.pending_kill_talk_count], 0) + 1)

    if runtime.cache[CACHE_KEYS.kill_task] ~= nil then
        return
    end

    local delay_min = math.max(0, get_number(config.kill_talk_delay_min, DEFAULT_KILL_TALK_DELAY_MIN))
    local delay_max = math.max(delay_min, get_number(config.kill_talk_delay_max, DEFAULT_KILL_TALK_DELAY_MAX))
    local delay = delay_min + math.random() * (delay_max - delay_min)

    runtime.cache[CACHE_KEYS.kill_task] = runtime.inst:DoTaskInTime(delay, function()
        runtime.cache[CACHE_KEYS.kill_task] = nil
        local pending_count = math.max(1, math.floor(get_number(state[STATE_KEYS.pending_kill_talk_count], 1)))
        state[STATE_KEYS.pending_kill_talk_count] = 0
        local base_chance = clamp(get_number(config.kill_talk_chance, DEFAULT_KILL_TALK_CHANCE), 0, 1)
        local bonus_chance = math.min(0.45, (pending_count - 1) * 0.15)
        local talk_chance = clamp(base_chance + bonus_chance, 0, 1)
        if math.random() <= talk_chance then
            talk_from_pool(runtime, TALK_POOL_KILL_REGEN, config, true)
        end
        schedule_random_talk(runtime, config)
    end)
end

local function remove_cached_callback(runtime, inst, event_name, cache_key)
    local callback = runtime.cache[cache_key]
    if callback ~= nil then
        inst:RemoveEventCallback(event_name, callback)
        runtime.cache[cache_key] = nil
    end
end

local function stop_cached_world_watcher(runtime, inst, world_state_name, cache_key)
    local callback = runtime.cache[cache_key]
    if callback ~= nil then
        inst:StopWatchingWorldState(world_state_name, callback)
        runtime.cache[cache_key] = nil
    end
end

---@param inst ent
---@param runtime component_rose_weapon_runtime
---@param config table
---@description 初始化黑鸦活物对白能力：注册监听、状态初始化与随机会话任务。
function ability.Init(inst, runtime, config)
    if config == nil or config.enabled == false then
        return
    end

    ensure_state_defaults(runtime)
    runtime.cache[CACHE_KEYS.owner_ref] = get_grand_owner(inst)

    runtime.cache[CACHE_KEYS.on_built] = function(_inst, data)
        local builder = data ~= nil and data.builder or nil
        if builder ~= nil then
            set_bound_userid(runtime, builder.userid)
        end
    end
    inst:ListenForEvent("onbuilt", runtime.cache[CACHE_KEYS.on_built])

    runtime.cache[CACHE_KEYS.on_put_in_inventory] = function(_inst, owner)
        enforce_bound_owner(runtime, owner, config)
        schedule_random_talk(runtime, config)
    end
    inst:ListenForEvent("onputininventory", runtime.cache[CACHE_KEYS.on_put_in_inventory])

    runtime.cache[CACHE_KEYS.on_dropped] = function()
        runtime.cache[CACHE_KEYS.owner_ref] = nil
        local ground_event_chance = clamp(get_number(config.ground_event_chance, DEFAULT_GROUND_EVENT_CHANCE), 0, 1)
        if math.random() <= ground_event_chance then
            talk_from_pool(runtime, TALK_POOL_GROUND, config, false)
        end
        schedule_random_talk(runtime, config)
    end
    inst:ListenForEvent("ondropped", runtime.cache[CACHE_KEYS.on_dropped])

    runtime.cache[CACHE_KEYS.on_equipped] = function(_inst, data)
        runtime.cache[CACHE_KEYS.owner_ref] = (data ~= nil and data.owner) or get_grand_owner(inst)
        enforce_bound_owner(runtime, runtime.cache[CACHE_KEYS.owner_ref], config)
        schedule_random_talk(runtime, config)
    end
    inst:ListenForEvent("equipped", runtime.cache[CACHE_KEYS.on_equipped])

    runtime.cache[CACHE_KEYS.on_unequipped] = function()
        runtime.cache[CACHE_KEYS.owner_ref] = get_grand_owner(inst)
        schedule_random_talk(runtime, config)
    end
    inst:ListenForEvent("unequipped", runtime.cache[CACHE_KEYS.on_unequipped])

    runtime.cache[CACHE_KEYS.on_nightvision_toggled] = function(_inst, data)
        on_nightvision_toggled(runtime, data, config)
    end
    inst:ListenForEvent(EVENT_NIGHTVISION_TOGGLED, runtime.cache[CACHE_KEYS.on_nightvision_toggled])

    runtime.cache[CACHE_KEYS.on_kill_regen] = function(_inst, data)
        on_kill_regen(runtime, data, config)
    end
    inst:ListenForEvent(EVENT_KILL_REGEN, runtime.cache[CACHE_KEYS.on_kill_regen])

    runtime.cache[CACHE_KEYS.watch_isdusk] = function(_inst, is_dusk)
        on_worldstate_dusk(runtime, is_dusk, config)
    end
    inst:WatchWorldState("isdusk", runtime.cache[CACHE_KEYS.watch_isdusk])

    runtime.cache[CACHE_KEYS.watch_isnight] = function(_inst, is_night)
        on_worldstate_night(runtime, is_night, config)
    end
    inst:WatchWorldState("isnight", runtime.cache[CACHE_KEYS.watch_isnight])

    runtime.cache[CACHE_KEYS.watch_isnewmoon] = function(_inst, is_new_moon)
        on_worldstate_newmoon(runtime, is_new_moon, config)
    end
    inst:WatchWorldState("isnewmoon", runtime.cache[CACHE_KEYS.watch_isnewmoon])

    runtime.cache[CACHE_KEYS.watch_isfullmoon] = function(_inst, is_full_moon)
        on_worldstate_fullmoon(runtime, is_full_moon, config)
    end
    inst:WatchWorldState("isfullmoon", runtime.cache[CACHE_KEYS.watch_isfullmoon])

    inst:DoTaskInTime(0, function()
        enforce_bound_owner(runtime, get_grand_owner(inst), config)
    end)

    schedule_random_talk(runtime, config, 8 + math.random() * 6)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param config table
---@description 装备时刷新拥有者缓存，执行绑定校验并重排随机会话。
function ability.OnEquip(runtime, owner, config)
    if config == nil or config.enabled == false then
        return
    end

    runtime.cache[CACHE_KEYS.owner_ref] = owner or get_grand_owner(runtime.inst)
    enforce_bound_owner(runtime, runtime.cache[CACHE_KEYS.owner_ref], config)
    schedule_random_talk(runtime, config)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@param config table
---@description 卸下时保留监听，仅更新拥有者上下文并维持低频随机会话。
function ability.OnUnequip(runtime, owner, config)
    if config == nil or config.enabled == false then
        return
    end

    runtime.cache[CACHE_KEYS.owner_ref] = get_grand_owner(runtime.inst) or owner
    schedule_random_talk(runtime, config)
end

---@param runtime component_rose_weapon_runtime
---@param _config table
---@description 移除时清理任务与事件监听，防止残留回调和任务泄漏。
function ability.OnRemove(runtime, _config)
    local inst = runtime ~= nil and runtime.inst or nil
    if runtime == nil or inst == nil then
        return
    end

    cancel_cache_task(runtime, CACHE_KEYS.random_task)
    cancel_cache_task(runtime, CACHE_KEYS.kill_task)
    runtime.cache[CACHE_KEYS.owner_ref] = nil

    remove_cached_callback(runtime, inst, "onbuilt", CACHE_KEYS.on_built)
    remove_cached_callback(runtime, inst, "onputininventory", CACHE_KEYS.on_put_in_inventory)
    remove_cached_callback(runtime, inst, "ondropped", CACHE_KEYS.on_dropped)
    remove_cached_callback(runtime, inst, "equipped", CACHE_KEYS.on_equipped)
    remove_cached_callback(runtime, inst, "unequipped", CACHE_KEYS.on_unequipped)
    remove_cached_callback(runtime, inst, EVENT_NIGHTVISION_TOGGLED, CACHE_KEYS.on_nightvision_toggled)
    remove_cached_callback(runtime, inst, EVENT_KILL_REGEN, CACHE_KEYS.on_kill_regen)

    stop_cached_world_watcher(runtime, inst, "isdusk", CACHE_KEYS.watch_isdusk)
    stop_cached_world_watcher(runtime, inst, "isnight", CACHE_KEYS.watch_isnight)
    stop_cached_world_watcher(runtime, inst, "isnewmoon", CACHE_KEYS.watch_isnewmoon)
    stop_cached_world_watcher(runtime, inst, "isfullmoon", CACHE_KEYS.watch_isfullmoon)
end

return ability
