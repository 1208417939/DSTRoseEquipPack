local ability = {
    id = "hamstring",
}

local HAMSTRING_TARGET_KEY = "hamstring_target"
local HAMSTRING_CALLBACK_KEY = "hamstring_locomote_callback"
local HAMSTRING_LAST_TICK_KEY = "hamstring_last_tick_time"
local HAMSTRING_CLEANUP_TASK_KEY = "hamstring_cleanup_task"

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

---@param value any
---@param default_value number
---@return number
---@description 标准化概率值，若是大于 1 的数字则缩小 100 倍，并限制在 0~1 之间。
local function normalize_chance(value, default_value)
    local chance = get_number(value, default_value)
    if chance > 1 then
        chance = chance / 100
    end
    return math.min(math.max(chance, 0), 1)
end

---@param runtime table
---@description 清理断筋监听器与相关缓存状态。
local function cleanup_hamstring_listener(runtime)
    local cache = runtime.cache
    local target = cache[HAMSTRING_TARGET_KEY]
    local callback = cache[HAMSTRING_CALLBACK_KEY]
    local cleanup_task = cache[HAMSTRING_CLEANUP_TASK_KEY]

    if target ~= nil and callback ~= nil then
        runtime.inst:RemoveEventCallback("locomote", callback, target)
    end

    if cleanup_task ~= nil then
        cleanup_task:Cancel()
    end

    cache[HAMSTRING_TARGET_KEY] = nil
    cache[HAMSTRING_CALLBACK_KEY] = nil
    cache[HAMSTRING_LAST_TICK_KEY] = nil
    cache[HAMSTRING_CLEANUP_TASK_KEY] = nil
end

---@param target table
---@description 在目标位置生成断筋命中特效。
local function spawn_hamstring_hit_fx(target)
    local fx = SpawnPrefab("peghook_hitfx")
    if fx == nil then
        return
    end

    fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    fx.AnimState:SetMultColour(200 / 255, 30 / 255, 30 / 255, 1)
end

---@param target table
---@description 在目标位置生成断筋移动伤害特效。
local function spawn_move_damage_fx(target)
    local x, y, z = target.Transform:GetWorldPosition()
    local fx = SpawnPrefab("shadowstrike_slash_fx")
    if fx == nil then
        return
    end

    fx.Transform:SetScale(0.1 * math.random(3, 12), 0.1 * math.random(3, 12), 0.1 * math.random(3, 12))
    fx.Transform:SetPosition(
        x + 0.3 * math.random(1, 5) - 0.3 * math.random(1, 5),
        y + 0.3 * math.random(1, 5) - 0.3 * math.random(1, 5),
        z + 0.3 * math.random(1, 5) - 0.3 * math.random(1, 5)
    )
end

---@param context table
---@param config table
---@description 攻击命中后触发，判定能否给目标施加断筋状态。目标处于断筋状态时移动受损。
function ability.OnAttackPost(context, config)
    local runtime = context.runtime
    local target = context.target
    local attacker = context.attacker
    if target == nil or attacker == nil or target.components == nil or target.components.locomotor == nil then
        return
    end

    local state = runtime:GetAbilityState(ability.id)
    state.charge_count = state.charge_count or 0

    local charge_chance = normalize_chance(config.charge_chance, 0)
    if math.random() > charge_chance then
        return
    end

    state.charge_count = state.charge_count + 1
    local required_charge_count = math.max(1, math.floor(get_number(config.required_charge_count, 1)))
    if state.charge_count < required_charge_count then
        return
    end

    spawn_hamstring_hit_fx(target)

    local tick_damage = get_number(config.tick_damage, 0)
    local min_tick_interval = math.max(0.03, get_number(config.check_period, 0.1))
    local effect_duration = math.max(0.1, get_number(config.effect_duration, 1))

    cleanup_hamstring_listener(runtime)

    runtime.cache[HAMSTRING_TARGET_KEY] = target
    runtime.cache[HAMSTRING_LAST_TICK_KEY] = 0
    runtime.cache[HAMSTRING_CALLBACK_KEY] = function(target_inst)
        if attacker == nil or (attacker.IsValid ~= nil and not attacker:IsValid()) then
            cleanup_hamstring_listener(runtime)
            return
        end

        if target_inst == nil or target_inst.components == nil or target_inst.components.health == nil or target_inst.components.combat == nil then
            cleanup_hamstring_listener(runtime)
            return
        end

        if target_inst.components.health:IsDead() then
            cleanup_hamstring_listener(runtime)
            return
        end

        if not target_inst.components.locomotor.wantstomoveforward then
            return
        end

        local now = GetTime()
        local last_tick_time = runtime.cache[HAMSTRING_LAST_TICK_KEY] or 0
        if now - last_tick_time < min_tick_interval then
            return
        end

        runtime.cache[HAMSTRING_LAST_TICK_KEY] = now
        target_inst.components.combat:GetAttacked(attacker, tick_damage)
        spawn_move_damage_fx(target_inst)
    end

    runtime.inst:ListenForEvent("locomote", runtime.cache[HAMSTRING_CALLBACK_KEY], target)
    runtime.cache[HAMSTRING_CLEANUP_TASK_KEY] = context.inst:DoTaskInTime(effect_duration, function()
        cleanup_hamstring_listener(runtime)
    end)

    state.charge_count = 0
end

---@param runtime table
---@param _owner table
---@param _config table
---@description 武器卸下时清理断筋效果。
function ability.OnUnequip(runtime, _owner, _config)
    cleanup_hamstring_listener(runtime)
end

return ability
