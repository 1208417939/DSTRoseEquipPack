local sakura_fx = {}

local function ensure_fx_instance(inst, fx_prefab_name)
    if inst.particle_fx ~= nil then
        return inst.particle_fx
    end

    local fx = SpawnPrefab(fx_prefab_name)
    if fx == nil then
        return nil
    end

    fx.entity:SetParent(inst.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, nil, 0, 0, 0)
    inst.particle_fx = fx
    return fx
end

function sakura_fx.build_controller(config)
    local enabled = config ~= nil and config.enabled == true
    local fx_prefab_name = config ~= nil and config.fx_prefab_name or nil

    local function ensure_fx(inst)
        if not enabled or fx_prefab_name == nil then
            return nil
        end

        return ensure_fx_instance(inst, fx_prefab_name)
    end

    local controller = {}

    function controller.set_emitter_state(inst, emitter_enabled)
        if not enabled then
            return
        end

        local fx = ensure_fx(inst)
        if fx == nil then
            return
        end

        if emitter_enabled then
            EmitterManager:Wake(fx)
        else
            EmitterManager:Hibernate(fx)
        end
    end

    function controller.preload_restore(inst)
        if not enabled then
            return
        end

        local fx = ensure_fx(inst)
        if fx == nil then
            return
        end

        if inst.components ~= nil and inst.components.equippable ~= nil and not inst.components.equippable:IsEquipped() then
            EmitterManager:Hibernate(fx)
        end
    end

    return controller
end

return sakura_fx
