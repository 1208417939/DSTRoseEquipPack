local ability = {
    id = "tri_circle",
}

local TRI_STATE_MAP_KEY = "rose_tri_circle_state_map"

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

---@param weapon table
---@return string
---@description 获取武器对应的标记键值。
local function get_weapon_state_key(weapon)
    if weapon ~= nil and weapon.prefab ~= nil then
        return weapon.prefab
    end
    return "unknown_weapon"
end

---@param target table
---@param weapon table
---@return table
---@description 获取或初始化目标身上的三环状态数据。
local function get_weapon_tri_state(target, weapon)
    target[TRI_STATE_MAP_KEY] = target[TRI_STATE_MAP_KEY] or {}

    local weapon_key = get_weapon_state_key(weapon)
    local weapon_state = target[TRI_STATE_MAP_KEY][weapon_key]
    if weapon_state == nil then
        weapon_state = {
            count = 0,
            fx_1 = nil,
            fx_2 = nil,
        }
        target[TRI_STATE_MAP_KEY][weapon_key] = weapon_state
    end

    return weapon_state
end

---@param weapon_state table
---@description 清除三环标记对应的跟随特效。
local function remove_circle_fx(weapon_state)
    if weapon_state.fx_1 ~= nil then
        weapon_state.fx_1:Remove()
        weapon_state.fx_1 = nil
    end

    if weapon_state.fx_2 ~= nil then
        weapon_state.fx_2:Remove()
        weapon_state.fx_2 = nil
    end
end

---@param target table
---@param scale number
---@return table|nil
---@description 生成三环层级的跟随特效片段。
local function spawn_follower_fx(target, scale)
    local fx = SpawnPrefab("reticule")
    if fx == nil then
        return nil
    end

    fx.Transform:SetScale(scale, scale, scale)
    fx.entity:SetParent(target.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(target.GUID, nil, 0, 0, 0)
    return fx
end

---@param context table
---@param config table
---@description 攻击命中后触发，累计攻击次数叠加三环印记。满三层时引爆标记，造成目标最大生命值百分比的额外伤害。
function ability.OnAttackPost(context, config)
    local target = context.target
    local attacker = context.attacker
    local weapon = context.inst

    if weapon == nil or target == nil or attacker == nil then
        return
    end

    if target.components == nil or target.components.health == nil or target.components.combat == nil then
        return
    end

    if target.components.health:IsDead() then
        return
    end

    local weapon_state = get_weapon_tri_state(target, weapon)
    weapon_state.count = (weapon_state.count or 0) + 1

    if weapon_state.count == 1 and weapon_state.fx_1 == nil then
        weapon_state.fx_1 = spawn_follower_fx(target, 1.5)
    elseif weapon_state.count == 2 and weapon_state.fx_2 == nil then
        weapon_state.fx_2 = spawn_follower_fx(target, 2)
    elseif weapon_state.count >= 3 then
        remove_circle_fx(weapon_state)

        local fx = SpawnPrefab("explode_small_slurtlehole")
        if fx ~= nil then
            fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            fx.Transform:SetScale(math.random(2, 5) / 2, math.random(2, 5) / 2, math.random(2, 5) / 2)
        end

        if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/whip_large")
        end

        local percentage_dmg = get_number(config.max_health_damage_percent, 0) / 100
        local bonus_dmg = target.components.health.maxhealth * percentage_dmg
        if bonus_dmg > 0 then
            target.components.combat:GetAttacked(attacker, bonus_dmg)
        end

        weapon_state.count = 0
    end
end

return ability
