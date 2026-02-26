local function int_colour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local MAX_LIFETIME = 4
local SHADER = "shaders/vfx_particle.ksh"

local function make_sakura_rain(weapon_name)
    local TEXTURE = resolvefilepath("fx/" .. weapon_name .. "_petal_sakura.tex")
    local COLOUR_ENVELOPE_NAME = weapon_name .. "_sakura_rain_colourenvelope"
    local SCALE_ENVELOPE_NAME = weapon_name .. "_sakura_rain_scaleenvelope"

    local assets = {
        Asset("IMAGE", TEXTURE),
        Asset("SHADER", SHADER),
    }

    local envelope_initialized = false

    local function init_envelope()
        if EnvelopeManager and not envelope_initialized then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
                { 0, int_colour(255, 255, 255, 0) },
                { 0.5, int_colour(255, 255, 255, 255) },
                { 0.7, int_colour(255, 255, 255, 170) },
                { 1, int_colour(255, 255, 255, 0) },
            })
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME, { { 0, { 1, 1 } } })
            envelope_initialized = true
        end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        inst:AddTag("FX")
        inst.entity:SetPristine()
        inst.persists = false

        if TheNet:IsDedicated() then
            return inst
        elseif not envelope_initialized then
            init_envelope()
        end

        local effect = inst.entity:AddVFXEffect()
        local num_emitters = 1
        effect:InitEmitters(1)

        for i = 1, num_emitters do
            effect:SetRenderResources(i, TEXTURE, SHADER)
            effect:SetRotationStatus(i, true)
            effect:SetUVFrameSize(i, 1, 1)
            effect:SetMaxNumParticles(i, 200)
            effect:SetMaxLifetime(i, MAX_LIFETIME)
            effect:SetColourEnvelope(i, COLOUR_ENVELOPE_NAME)
            effect:SetScaleEnvelope(i, SCALE_ENVELOPE_NAME)
            effect:SetBlendMode(i, BLENDMODE.Premultiplied)
            effect:EnableBloomPass(i, true)
            effect:SetSortOrder(i, 0)
            effect:SetSortOffset(i, 0)
            effect:SetGroundPhysics(i, true)
            effect:SetAcceleration(i, 0, -0.08, 0)
            effect:SetDragCoefficient(i, 0.03)
        end

        local function throttle_emitter(fn_emit)
            local timer = nil
            return function()
                if timer == nil then
                    timer = inst:DoTaskInTime(0.4, function()
                        fn_emit()
                        timer = nil
                    end)
                end
            end
        end

        local emit = throttle_emitter(function()
            for i = 1, 1 do
                local num_to_emit = 10
                while num_to_emit > 0 do
                    local px, pz = CreateCircleEmitter(3)()
                    effect:AddRotatingParticleUV(
                        i,
                        MAX_LIFETIME * (0.5 + UnitRand() * 0.5),
                        px, 5, pz,
                        0, -0.08, 0.06,
                        math.random() * 360, (UnitRand() - 0.5) * 2,
                        0, 0
                    )
                    num_to_emit = num_to_emit - 1
                end
            end
        end)

        inst.emiter_adder = function()
            EmitterManager:AddEmitter(inst, nil, function()
                emit()
            end)
        end
        inst.emiter_adder()

        return inst
    end

    return Prefab(weapon_name .. "_sakura_rain", fn, assets)
end

local weapons_with_sakura_rain = {
    "roseaxe",
    "rosegunflag",
    "rosescissors",
    "roseparasol",
    "rosefrostwand",
    "oceantrident",
    "crowscythe",
    "naturetoolswand",
}

local prefabs = {}
for _, weapon in ipairs(weapons_with_sakura_rain) do
    table.insert(prefabs, make_sakura_rain(weapon))
end

return unpack(prefabs)
