local damage_pipeline = require("rose_core/damage_pipeline")
local progression_service = require("rose_core/progression_service")

local rose_weapon_runtime = Class(function(self, inst)
    self.inst = inst
    self.weapon_def = nil
    self.runtime_config = nil
    self.state = {
        progress = {},
        ability_state_map = {},
        damage = {
            level = 0,
            bonus = 0,
        },
    }
    self.cache = {}
    self.abilities = {}
end)

local function clear_cache_tasks(self)
    for _, value in pairs(self.cache) do
        local ok, has_cancel = pcall(function()
            return value ~= nil and value.Cancel ~= nil
        end)
        if ok and has_cancel then
            pcall(function()
                value:Cancel()
            end)
        end
    end
    self.cache = {}
end

local function get_number(value, default_value)
    if type(value) == "number" then
        return value
    end
    return default_value
end

local function is_ability_enabled(ability_entry)
    return ability_entry ~= nil and (ability_entry.config == nil or ability_entry.config.enabled ~= false)
end

local function ensure_state_shape(self)
    self.state = self.state or {}
    self.state.progress = self.state.progress or {}
    self.state.ability_state_map = self.state.ability_state_map or {}
    self.state.damage = self.state.damage or {}
    self.state.damage.level = get_number(self.state.damage.level, 0)
    self.state.damage.bonus = get_number(self.state.damage.bonus, 0)
end

function rose_weapon_runtime:GetBaseDamage()
    if self.weapon_def == nil or self.weapon_def.combat == nil then
        return 0
    end

    return get_number(self.weapon_def.combat.base_damage, 0)
end

function rose_weapon_runtime:GetDamageState()
    ensure_state_shape(self)
    return self.state.damage
end

function rose_weapon_runtime:GetDamageBonus()
    return self:GetDamageState().bonus
end

function rose_weapon_runtime:GetCurrentDamage()
    return self:GetBaseDamage() + self:GetDamageBonus()
end

function rose_weapon_runtime:GetGrowthCurve()
    if self.weapon_def == nil or self.weapon_def.progression == nil then
        return nil
    end
    return self.weapon_def.progression.growth_curve
end

function rose_weapon_runtime:SyncWeaponDamage()
    if self.inst.components == nil or self.inst.components.weapon == nil then
        return
    end

    self.inst.components.weapon:SetDamage(self:GetCurrentDamage())
end

function rose_weapon_runtime:Setup(weapon_def, runtime_config)
    self.weapon_def = weapon_def
    self.runtime_config = runtime_config or { enabled = true, abilities = {} }
    self.abilities = {}
    ensure_state_shape(self)

    local ability_order = weapon_def and weapon_def.ability_order or nil
    local ability_modules = weapon_def and weapon_def.ability_modules or nil
    if ability_order == nil or ability_modules == nil then
        self:SyncWeaponDamage()
        return
    end

    for _, ability_name in ipairs(ability_order) do
        local module_path = ability_modules[ability_name]
        if module_path ~= nil then
            local ability = require(module_path)
            local ability_config = self:GetAbilityConfig(ability_name)
            local ability_entry = {
                name = ability_name,
                module = ability,
                config = ability_config,
            }
            table.insert(self.abilities, ability_entry)
            if ability.Init ~= nil then
                ability.Init(self.inst, self, ability_config)
            end
        end
    end

    self:SyncWeaponDamage()
end

function rose_weapon_runtime:IsEnabled()
    return self.runtime_config == nil or self.runtime_config.enabled ~= false
end

function rose_weapon_runtime:GetAbilityConfig(ability_name)
    if self.runtime_config == nil or self.runtime_config.abilities == nil then
        return { enabled = true }
    end

    return self.runtime_config.abilities[ability_name] or { enabled = true }
end

function rose_weapon_runtime:GetAbilityState(ability_name)
    ensure_state_shape(self)
    local ability_state_map = self.state.ability_state_map
    if ability_state_map[ability_name] == nil then
        ability_state_map[ability_name] = {}
    end
    return ability_state_map[ability_name]
end

function rose_weapon_runtime:ResolveUpgradeValue(item)
    return progression_service.ResolveGoldValue(item)
end

function rose_weapon_runtime:CanAcceptUpgradeItem(item)
    if item == nil or not self:IsEnabled() then
        return false
    end

    local upgrade_config = self:GetAbilityConfig("upgrade_by_gold")
    if upgrade_config.enabled == false then
        return false
    end

    return progression_service.CanUpgradeByItem(item, upgrade_config.accepted_prefab)
end

function rose_weapon_runtime:ApplyProgress(delta, reason)
    local result = progression_service.ApplyProgress(self:GetDamageState(), delta, self:GetGrowthCurve())
    if result.applied then
        result.reason = reason
        self:SyncWeaponDamage()
    end
    return result
end

function rose_weapon_runtime:ComputeDamageResult(multiplier)
    return damage_pipeline.Compute(self:GetBaseDamage(), self:GetDamageBonus(), multiplier)
end

function rose_weapon_runtime:ComputeBonusDamage(multiplier)
    local result = self:ComputeDamageResult(multiplier)
    return result.bonus_damage
end

---@param inst ent
---@param attacker ent
---@param target ent
---@return table
---@description 构建攻击上下文，供能力插件读取与写入。
function rose_weapon_runtime:BuildAttackContext(inst, attacker, target)
    return {
        inst = inst,
        attacker = attacker,
        target = target,
        runtime = self,
        damage_multiplier = 1,
        damage_result = nil,
    }
end

---@param inst ent
---@param target ent|nil
---@param pos Vector3|table|nil
---@param doer ent|nil
---@return table
---@description 构建法术上下文，统一法术能力插件调用参数。
function rose_weapon_runtime:BuildSpellContext(inst, target, pos, doer)
    return {
        inst = inst,
        target = target,
        pos = pos,
        doer = doer,
        runtime = self,
    }
end

---@param context table
---@description 执行一次攻击伤害结算，并回填 damage_result。
function rose_weapon_runtime:ApplyAttackDamage(context)
    local attacker = context.attacker
    local target = context.target
    if attacker == nil or target == nil then
        return
    end

    if target.components == nil or target.components.combat == nil then
        return
    end

    local damage_result = self:ComputeDamageResult(context.damage_multiplier)
    target.components.combat:GetAttacked(attacker, damage_result.bonus_damage)
    context.damage_result = damage_result
end

---@param inst ent
---@param attacker ent
---@param target ent
---@description 统一攻击链路：OnAttackPre -> ApplyAttackDamage -> OnAttackPost。
function rose_weapon_runtime:OnAttack(inst, attacker, target)
    if not self:IsEnabled() then
        return
    end

    local context = self:BuildAttackContext(inst, attacker, target)
    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnAttackPre ~= nil and is_ability_enabled(ability_entry) then
            ability.OnAttackPre(context, ability_entry.config)
        end
    end

    self:ApplyAttackDamage(context)

    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnAttackPost ~= nil and is_ability_enabled(ability_entry) then
            ability.OnAttackPost(context, ability_entry.config)
        end
    end
end

---@param inst ent
---@param giver ent
---@param item ent
---@return boolean
---@description 分发喂养事件给能力插件，并返回是否被处理。
function rose_weapon_runtime:OnAcceptItem(inst, giver, item)
    if not self:IsEnabled() then
        return false
    end

    local context = {
        inst = inst,
        giver = giver,
        item = item,
        runtime = self,
        handled = false,
    }

    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnAcceptItem ~= nil and is_ability_enabled(ability_entry) then
            ability.OnAcceptItem(context, ability_entry.config)
        end
    end

    return context.handled
end

---@param inst ent
---@param target ent|nil
---@param pos Vector3|table|nil
---@param doer ent|nil
---@return boolean
---@description 统一判定法术是否可施放，至少需要一个启用的法术处理器。
function rose_weapon_runtime:CanCastSpell(inst, target, pos, doer)
    if not self:IsEnabled() then
        return false
    end

    local context = self:BuildSpellContext(inst, target, pos, doer)
    local has_spell_handler = false

    for _, ability_entry in ipairs(self.abilities) do
        if is_ability_enabled(ability_entry) then
            local ability = ability_entry.module
            if ability.OnCastSpell ~= nil then
                has_spell_handler = true
            end

            if ability.OnCanCastSpell ~= nil then
                local can_cast = ability.OnCanCastSpell(context, ability_entry.config)
                if can_cast == false then
                    return false
                end
                if can_cast == true then
                    has_spell_handler = true
                end
            end
        end
    end

    return has_spell_handler
end

---@param inst ent
---@param target ent|nil
---@param pos Vector3|table|nil
---@param doer ent|nil
---@description 分发法术施放事件给已启用的能力插件。
function rose_weapon_runtime:OnCastSpell(inst, target, pos, doer)
    if not self:IsEnabled() then
        return
    end

    local context = self:BuildSpellContext(inst, target, pos, doer)
    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnCastSpell ~= nil and is_ability_enabled(ability_entry) then
            ability.OnCastSpell(context, ability_entry.config)
        end
    end
end

---@param inst ent
---@param doer ent|nil
---@return table
---@description 构建右键使用上下文，供可交互能力读取与写入。
function rose_weapon_runtime:BuildUseItemContext(inst, doer)
    return {
        inst = inst,
        doer = doer,
        runtime = self,
        handled = false,
    }
end

---@param inst ent
---@param doer ent|nil
---@return boolean
---@description 分发装备右键使用事件给已启用能力。
function rose_weapon_runtime:OnUseItem(inst, doer)
    if not self:IsEnabled() then
        return false
    end

    local context = self:BuildUseItemContext(inst, doer)
    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnUseItem ~= nil and is_ability_enabled(ability_entry) then
            ability.OnUseItem(context, ability_entry.config)
        end
    end

    return context.handled
end

---@param owner ent|nil
---@description 分发装备事件给能力插件。
function rose_weapon_runtime:OnEquip(owner)
    if not self:IsEnabled() then
        return
    end

    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnEquip ~= nil and is_ability_enabled(ability_entry) then
            ability.OnEquip(self, owner, ability_entry.config)
        end
    end
end

---@param owner ent|nil
---@description 分发卸下事件，允许能力在武器卸下时做资源清理。
function rose_weapon_runtime:OnUnequip(owner)
    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnUnequip ~= nil then
            ability.OnUnequip(self, owner, ability_entry.config)
        end
    end
end

function rose_weapon_runtime:OnSave()
    ensure_state_shape(self)
    return {
        state = self.state,
    }
end

function rose_weapon_runtime:OnLoad(data)
    if data ~= nil and data.state ~= nil then
        self.state = data.state
    end

    ensure_state_shape(self)
    self:SyncWeaponDamage()
end

function rose_weapon_runtime:OnRemoveFromEntity()
    self:OnUnequip(nil)

    for _, ability_entry in ipairs(self.abilities) do
        local ability = ability_entry.module
        if ability.OnRemove ~= nil then
            ability.OnRemove(self, ability_entry.config)
        end
    end

    clear_cache_tasks(self)
end

return rose_weapon_runtime
