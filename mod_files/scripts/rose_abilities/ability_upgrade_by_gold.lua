local ability = {
    id = "upgrade_by_gold",
}

---@param context table
---@param _config table
---@description 接收物品时触发，判定是否为允许的强化材料（如黄金），并进行数值喂养转化，播放相应音效。
function ability.OnAcceptItem(context, _config)
    local inst = context.inst
    local runtime = context.runtime
    local item = context.item
    if inst == nil or runtime == nil or item == nil then
        return
    end

    if not runtime:CanAcceptUpgradeItem(item) then
        return
    end

    local gold_value = runtime:ResolveUpgradeValue(item)
    if gold_value <= 0 then
        return
    end

    local result = runtime:ApplyProgress(gold_value, ability.id)
    if result ~= nil and result.applied then
        if inst.SoundEmitter ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
        end
        context.handled = true
    end
end

return ability
