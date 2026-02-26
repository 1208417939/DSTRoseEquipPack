local ability = {
    id = "walk_on_water",
}

local WALK_ON_WATER_TAG = "rose_walk_on_water"
local OWNER_CACHE_KEY = "walk_on_water_owner"
local PREVIOUS_DROWNABLE_ENABLED_KEY = "previous_drownable_enabled"

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

---@param runtime component_rose_weapon_runtime
---@param owner ent
---@description 应用踏水状态：关闭 drownable 并切换碰撞层。
local function apply_walk_on_water(runtime, owner)
    if not is_valid_owner(owner) then
        return
    end

    owner:AddTag(WALK_ON_WATER_TAG)
    runtime.cache[OWNER_CACHE_KEY] = owner

    if owner.components == nil or owner.components.drownable == nil then
        return
    end

    local state = runtime:GetAbilityState(ability.id)
    state[PREVIOUS_DROWNABLE_ENABLED_KEY] = owner.components.drownable.enabled
    owner.components.drownable.enabled = false
    refresh_owner_collision_mask(owner)
end

---@param runtime component_rose_weapon_runtime
---@param owner ent|nil
---@description 还原踏水状态：恢复 drownable 与碰撞层。
local function clear_walk_on_water(runtime, owner)
    local target_owner = owner or runtime.cache[OWNER_CACHE_KEY]
    if not is_valid_owner(target_owner) then
        runtime.cache[OWNER_CACHE_KEY] = nil
        return
    end

    target_owner:RemoveTag(WALK_ON_WATER_TAG)

    if target_owner.components ~= nil and target_owner.components.drownable ~= nil then
        local state = runtime:GetAbilityState(ability.id)
        local previous_enabled = state[PREVIOUS_DROWNABLE_ENABLED_KEY]
        target_owner.components.drownable.enabled = type(previous_enabled) == "boolean" and previous_enabled or true
        state[PREVIOUS_DROWNABLE_ENABLED_KEY] = nil
        refresh_owner_collision_mask(target_owner)
    end

    runtime.cache[OWNER_CACHE_KEY] = nil
end

---@param runtime component_rose_weapon_runtime
---@param owner ent
---@param _config table
---@description 装备时启用踏水能力。
function ability.OnEquip(runtime, owner, _config)
    apply_walk_on_water(runtime, owner)
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
    clear_walk_on_water(runtime, nil)
end

return ability
