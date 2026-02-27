-- rose axe
STRINGS.NAMES.ROSEAXE = "Rose Axe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEAXE = "Maintained with rose essential oil."
STRINGS.RECIPE_DESC.ROSEAXE = "Stay elegant even in battle."

-- rose gun flag
STRINGS.NAMES.ROSEGUNFLAG = "Rose Gun Flag"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEGUNFLAG = "The fragrance of roses inspires courage."
STRINGS.RECIPE_DESC.ROSEGUNFLAG = "A noble banner that shines with valor."

-- rose scissors
STRINGS.NAMES.ROSESCISSORS = "Rose Scissors"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSESCISSORS = "Time to trim the rose garden."
STRINGS.RECIPE_DESC.ROSESCISSORS = "Large and razor sharp."

-- rose parasol
STRINGS.NAMES.ROSEPARASOL = "Rose Parasol"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEPARASOL = "Hope it keeps the heat away."
STRINGS.RECIPE_DESC.ROSEPARASOL = "Walk safely across the ocean."

-- rose frost wand
STRINGS.NAMES.ROSEFROSTWAND = "Rose Frost Wand"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEFROSTWAND = "It gives off an icy aura."
STRINGS.RECIPE_DESC.ROSEFROSTWAND = "The first rose of winter."

-- ocean trident
STRINGS.NAMES.OCEANTRIDENT = "Ocean Trident"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OCEANTRIDENT = "A spear born to rule the sea."
STRINGS.RECIPE_DESC.OCEANTRIDENT = "Thunder and tide in one strike."

-- crow scythe
STRINGS.NAMES.CROWSCYTHE = "Crow Scythe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CROWSCYTHE = "The blade hums with black-feathered intent."
STRINGS.RECIPE_DESC.CROWSCYTHE = "Let the crows answer every swing."

-- nature tools wand
STRINGS.NAMES.NATURETOOLSWAND = "Nature Tool Wand"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.NATURETOOLSWAND = "One wand to gather and work."
STRINGS.RECIPE_DESC.NATURETOOLSWAND = "A wand shaped from the force of nature."

-- repair lines
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES = STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES or {}
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.FULL = "It's new, no repair needed."
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.INVALID = "Maybe I should try a different material."
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.SUCCESS = "Power of the rose, repair complete!"

local function setup_useitem_action_text_en()
    if ACTIONS == nil or ACTIONS.USEITEM == nil or STRINGS == nil or STRINGS.ACTIONS == nil then
        return
    end

    local useitem_strings = STRINGS.ACTIONS.USEITEM
    if type(useitem_strings) ~= "table" then
        STRINGS.ACTIONS.USEITEM = {
            GENERIC = useitem_strings or "Use",
        }
        useitem_strings = STRINGS.ACTIONS.USEITEM
    elseif useitem_strings.GENERIC == nil then
        useitem_strings.GENERIC = "Use"
    end

    useitem_strings.ROSEPARASOL_OPEN = "Open"
    useitem_strings.ROSEPARASOL_CLOSE = "Close"
    useitem_strings.CROWSCYTHE_OPEN = "Open"
    useitem_strings.CROWSCYTHE_CLOSE = "Close"

    if ACTIONS.USEITEM.rose_equip_pack_strfn_wrapped == true then
        return
    end

    ACTIONS.USEITEM.rose_equip_pack_strfn_wrapped = true
    local old_strfn = ACTIONS.USEITEM.strfn
    ACTIONS.USEITEM.strfn = function(act)
        local invobject = act ~= nil and act.invobject or nil
        if invobject ~= nil and invobject.prefab == "roseparasol" then
            return invobject:HasTag("rose_walk_on_water_enabled") and "ROSEPARASOL_CLOSE" or "ROSEPARASOL_OPEN"
        end

        if invobject ~= nil and invobject.prefab == "crowscythe" then
            return invobject:HasTag("nightvision") and "CROWSCYTHE_CLOSE" or "CROWSCYTHE_OPEN"
        end

        if old_strfn ~= nil then
            return old_strfn(act)
        end
    end
end

setup_useitem_action_text_en()
