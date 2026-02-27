local ability = {
    id = "shadow_oath",
}

local SHADOW_ALIGNED_TAG = "shadow_aligned"
local SHADOW_REJECT_FLAG = "shadow_oath_reject"
local DEFAULT_REJECT_COOLDOWN = 0.35
local DEFAULT_REJECT_SOUND = "dontstarve/sanity/creature2/taunt"
local NEGATIVE_TIME_SENTINEL = -1000000

local TALK_POOL_REJECT_SHADOW = "REJECT_SHADOW"
local TALK_POOL_REJECT_SHADOW_STRONGGRIP = "REJECT_SHADOW_STRONGGRIP"
local TALK_POOL_REJECT_FALLBACK = "REJECT"

local CACHE_KEY_WATCH_PHASE = "shadow_oath_watch_phase"
local STATE_KEY_LAST_REJECT_TIME = "last_reject_time"

local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

local function get_boolean(value, default_value)
    if type(value) == "boolean" then
        return value
    end
    return default_value
end

local function ensure_state(runtime)
    local state = runtime:GetAbilityState(ability.id)
    if type(state[STATE_KEY_LAST_REJECT_TIME]) ~= "number" then
        state[STATE_KEY_LAST_REJECT_TIME] = NEGATIVE_TIME_SENTINEL
    end
    return state
end

local function resolve_shadow_reject_config(config)
    local reject_cfg = type(config) == "table" and type(config.shadow_reject) == "table" and config.shadow_reject or {}
    return {
        enabled = get_boolean(reject_cfg.enabled, true),
        respect_stronggrip = get_boolean(reject_cfg.respect_stronggrip, true),
        drop_on_reject = get_boolean(reject_cfg.drop_on_reject, true),
        reject_cooldown = math.max(0, get_number(reject_cfg.reject_cooldown, DEFAULT_REJECT_COOLDOWN)),
        sound = type(reject_cfg.sound) == "string" and reject_cfg.sound or DEFAULT_REJECT_SOUND,
    }
end

local function resolve_phase_planar_damage(config, default_planar_damage)
    local phase_cfg = type(config) == "table" and type(config.phase_planar_damage) == "table" and config.phase_planar_damage or {}
    local day = math.max(0, get_number(phase_cfg.day, default_planar_damage))
    local dusk = math.max(0, get_number(phase_cfg.dusk, day))
    local night = math.max(0, get_number(phase_cfg.night, dusk))
    return {
        day = day,
        dusk = dusk,
        night = night,
    }
end

local function resolve_current_phase()
    local world_state = TheWorld ~= nil and TheWorld.state or nil
    local phase = world_state ~= nil and world_state.phase or nil
    if phase == "dusk" or phase == "night" then
        return phase
    end
    return "day"
end

local function get_talk_pool_lines(pool_key)
    local root = STRINGS ~= nil and STRINGS.CROWSCYTHE_TALK or nil
    local pool = root ~= nil and root[pool_key] or nil
    if type(pool) == "table" and type(pool[1]) == "string" then
        return pool
    end
    return nil
end

local function say_from_pool(inst, pool_key)
    if inst == nil or inst.components == nil then
        return false
    end

    local talker = inst.components.talker
    if talker == nil then
        return false
    end

    local lines = get_talk_pool_lines(pool_key)
    if lines == nil then
        return false
    end

    local line = lines[math.random(#lines)]
    if type(line) ~= "string" or line == "" then
        return false
    end

    talker:Say(line)
    return true
end

local function apply_phase_planar_damage(runtime, config, phase)
    local inst = runtime ~= nil and runtime.inst or nil
    if inst == nil or inst.components == nil or inst.components.planardamage == nil then
        return
    end

    if runtime.IsDurabilityBroken ~= nil and runtime:IsDurabilityBroken() then
        inst.components.planardamage:SetBaseDamage(0)
        return
    end

    local default_planar_damage = 0
    if runtime.weapon_def ~= nil and runtime.weapon_def.combat ~= nil then
        default_planar_damage = get_number(runtime.weapon_def.combat.planar_damage, 0)
    end
    local phase_planar_damage = resolve_phase_planar_damage(config, default_planar_damage)
    local phase_key = (phase == "dusk" or phase == "night") and phase or "day"
    inst.components.planardamage:SetBaseDamage(phase_planar_damage[phase_key] or phase_planar_damage.day)
end

local function ensure_shadow_damage_block(inst)
    if inst == nil or inst.components == nil then
        return
    end

    local damagetypebonus = inst.components.damagetypebonus
    if damagetypebonus == nil then
        inst:AddComponent("damagetypebonus")
        damagetypebonus = inst.components.damagetypebonus
    end

    if damagetypebonus ~= nil then
        damagetypebonus:AddBonus(SHADOW_ALIGNED_TAG, inst, 0, ability.id)
    end
end

local function remove_shadow_damage_block(inst)
    if inst == nil or inst.components == nil then
        return
    end

    local damagetypebonus = inst.components.damagetypebonus
    if damagetypebonus ~= nil then
        damagetypebonus:RemoveBonus(SHADOW_ALIGNED_TAG, inst, ability.id)
    end
end

local function should_drop_for_reject(inst, owner, reject_cfg)
    if reject_cfg.drop_on_reject ~= true then
        return false, false
    end

    if owner == nil or owner.components == nil or owner.components.inventory == nil then
        return false, false
    end

    local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped ~= inst then
        return false, false
    end

    if reject_cfg.respect_stronggrip == true and owner:HasTag("stronggrip") then
        return false, true
    end

    owner.components.inventory:DropItem(inst, true, true)
    return true, false
end

local function try_reject_feedback(runtime, attacker, config)
    local reject_cfg = resolve_shadow_reject_config(config)
    if reject_cfg.enabled ~= true then
        return
    end

    local inst = runtime.inst
    local _dropped, blocked_by_stronggrip = should_drop_for_reject(inst, attacker, reject_cfg)

    local state = ensure_state(runtime)
    local now = GetTime()
    local last_reject_time = get_number(state[STATE_KEY_LAST_REJECT_TIME], NEGATIVE_TIME_SENTINEL)
    if now - last_reject_time < reject_cfg.reject_cooldown then
        return
    end
    state[STATE_KEY_LAST_REJECT_TIME] = now

    if inst.SoundEmitter ~= nil and reject_cfg.sound ~= "" then
        inst.SoundEmitter:PlaySound(reject_cfg.sound)
    end

    local pool_key = blocked_by_stronggrip and TALK_POOL_REJECT_SHADOW_STRONGGRIP or TALK_POOL_REJECT_SHADOW
    if not say_from_pool(inst, pool_key) then
        say_from_pool(inst, TALK_POOL_REJECT_FALLBACK)
    end
end

---@param inst ent
---@param runtime component_rose_weapon_runtime
---@param config table
---@description 初始化暗影誓约：拦截 shadow_aligned 伤害并按时段同步位面伤害。
function ability.Init(inst, runtime, config)
    if config == nil or config.enabled == false then
        return
    end

    ensure_state(runtime)
    ensure_shadow_damage_block(inst)

    runtime.cache[CACHE_KEY_WATCH_PHASE] = function(_inst, phase)
        apply_phase_planar_damage(runtime, config, phase)
    end
    inst:WatchWorldState("phase", runtime.cache[CACHE_KEY_WATCH_PHASE])
    apply_phase_planar_damage(runtime, config, resolve_current_phase())
end

---@param context table
---@param config table
---@description 命中暗影阵营目标时，标记为拒斩并跳过 runtime 额外伤害层。
function ability.OnAttackPre(context, config)
    if context == nil or context.target == nil or config == nil or config.enabled == false then
        return
    end

    if context.target:HasTag(SHADOW_ALIGNED_TAG) then
        context.skip_runtime_damage = true
        context.flags = context.flags or {}
        context.flags[SHADOW_REJECT_FLAG] = true
    end
end

---@param context table
---@param config table
---@description 攻击暗影目标后触发抗拒反馈；若无 stronggrip 则执行脱手。
function ability.OnAttackPost(context, config)
    if context == nil or context.runtime == nil or config == nil or config.enabled == false then
        return
    end

    if type(context.flags) ~= "table" or context.flags[SHADOW_REJECT_FLAG] ~= true then
        return
    end

    try_reject_feedback(context.runtime, context.attacker, config)
end

---@param runtime component_rose_weapon_runtime
---@param _owner ent|nil
---@param config table
---@description 修复耐久后立即重同步当前时段位面伤害，避免等待下一次 phase 切换。
function ability.OnDurabilityRestored(runtime, _owner, config)
    if config == nil or config.enabled == false then
        return
    end
    apply_phase_planar_damage(runtime, config, resolve_current_phase())
end

---@param runtime component_rose_weapon_runtime
---@param _config table
---@description 清理 worldstate 监听并移除暗影伤害拦截，避免监听泄漏。
function ability.OnRemove(runtime, _config)
    if runtime == nil or runtime.inst == nil then
        return
    end

    local inst = runtime.inst
    local watcher = runtime.cache[CACHE_KEY_WATCH_PHASE]
    if watcher ~= nil then
        inst:StopWatchingWorldState("phase", watcher)
        runtime.cache[CACHE_KEY_WATCH_PHASE] = nil
    end

    remove_shadow_damage_block(inst)
end

return ability
