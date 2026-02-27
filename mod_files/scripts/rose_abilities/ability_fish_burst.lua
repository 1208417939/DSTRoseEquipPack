local ability = {
    id = "fish_burst",
}

local DEFAULT_RADIUS = 4
local DEFAULT_DURABILITY_COST = 5

local EXCLUDE_TAGS = { "INLIMBO", "outofreach", "DECOR" }

local INITIAL_LAUNCH_HEIGHT = 0.1
local LAUNCH_SPEED = 8

local PROJECTILE_HORIZONTAL_SPEED = 16
local PROJECTILE_GRAVITY = -30
local PROJECTILE_OFFSET = Vector3(0, 0.5, 0)

local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

local function resolve_position(pos)
    if pos == nil then
        return nil, nil, nil
    end

    if pos.Get ~= nil then
        return pos:Get()
    end

    return pos.x, pos.y, pos.z
end

local function resolve_cast_doer(context)
    if context == nil then
        return nil
    end

    if context.doer ~= nil then
        return context.doer
    end

    local inst = context.inst
    if inst ~= nil and inst.components ~= nil and inst.components.inventoryitem ~= nil then
        return inst.components.inventoryitem:GetGrandOwner()
    end

    return nil
end

local function launch_away(inst, burst_position)
    if inst == nil or inst.Transform == nil or inst.Physics == nil or burst_position == nil then
        return
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

    local px, py, pz = burst_position:Get()
    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(LAUNCH_SPEED * cosa, 4 + LAUNCH_SPEED, LAUNCH_SPEED * sina)
end

local function launch_fish_projectile(target, burst_position)
    if target == nil or target.components == nil or target.components.oceanfishable == nil then
        return false
    end

    local projectile = target.components.oceanfishable:MakeProjectile()
    if projectile == nil then
        return false
    end

    local complex_projectile = projectile.components ~= nil and projectile.components.complexprojectile or nil
    if complex_projectile ~= nil then
        complex_projectile:SetHorizontalSpeed(PROJECTILE_HORIZONTAL_SPEED)
        complex_projectile:SetGravity(PROJECTILE_GRAVITY)
        complex_projectile:SetLaunchOffset(PROJECTILE_OFFSET)
        complex_projectile:SetTargetOffset(PROJECTILE_OFFSET)

        local target_position = target:GetPosition()
        local launch_direction = target_position - burst_position
        if launch_direction:LengthSq() <= 0 then
            launch_direction = Vector3(1, 0, 0)
        else
            launch_direction = launch_direction:Normalize()
        end

        local launch_position = target_position + launch_direction * LAUNCH_SPEED
        complex_projectile:Launch(launch_position, projectile, complex_projectile.owningweapon)
    else
        launch_away(projectile, burst_position)
    end

    return true
end

local function consume_uses(inst, use_cost)
    if inst == nil or inst.components == nil or inst.components.finiteuses == nil then
        return
    end

    inst.components.finiteuses:Use(use_cost)
end

---@param context table
---@param _config table
---@return boolean
---@description 仅允许在海面点施法，行为与官方 trident 的炸鱼入口一致。
function ability.OnCanCastSpell(context, _config)
    if context == nil or context.pos == nil or TheWorld == nil or TheWorld.Map == nil then
        return false
    end

    local x, y, z = resolve_position(context.pos)
    if x == nil or y == nil or z == nil then
        return false
    end

    return TheWorld.Map:IsOceanAtPoint(x, y, z, false) and not TheWorld.Map:IsGroundTargetBlocked(context.pos)
end

---@param context table
---@param config table
---@description 海面爆发会将范围内 oceanfishable 转为抛射物，并消耗固定耐久。
function ability.OnCastSpell(context, config)
    if context == nil or context.pos == nil or TheSim == nil then
        return
    end

    config = config or {}

    local x, y, z = resolve_position(context.pos)
    if x == nil or y == nil or z == nil then
        return
    end

    local radius = math.max(0.1, get_number(config.radius, DEFAULT_RADIUS))
    local durability_cost = math.max(1, math.floor(get_number(config.durability_cost, DEFAULT_DURABILITY_COST)))
    local burst_position = Vector3(x, y, z)
    local doer = resolve_cast_doer(context)

    local entities = TheSim:FindEntities(x, y, z, radius, nil, EXCLUDE_TAGS, nil)
    for _, target in ipairs(entities) do
        if target ~= nil and target.components ~= nil and target.components.oceanfishable ~= nil then
            if target.IsOnOcean ~= nil and target:IsOnOcean(false) then
                if doer ~= nil and target.components.weighable ~= nil and target.components.weighable.SetPlayerAsOwner ~= nil then
                    target.components.weighable:SetPlayerAsOwner(doer)
                end
                launch_fish_projectile(target, burst_position)
            end
        end
    end

    consume_uses(context.inst, durability_cost)
end

return ability
