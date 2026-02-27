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
STRINGS.CROWSCYTHE_TALK = STRINGS.CROWSCYTHE_TALK or {}
STRINGS.CROWSCYTHE_TALK.DUSK_NIGHT = {
    "Sunset again. The ground is bleeding.",
    "That giant eye is staring blankly in the sky.",
    "Hush... the dark is still growing.",
    "Your shadow says it has had enough of you.",
    "A campfire chick, shivering in fear.",
    "The great star blinks, and sanity slips.",
}
STRINGS.CROWSCYTHE_TALK.GROUND = {
    "The soil reeks of crawling vermin.",
    "Do not leave me under that pale glare!",
    "I hear ancient wails beneath the dirt.",
    "No one but my contractor may touch me!",
}
STRINGS.CROWSCYTHE_TALK.FULLMOON = {
    "That giant eye has gone mad. Blinding.",
    "Moonlight is squeezed-out pus. Revolting.",
    "So wide open, yet still blind.",
    "Cut the white light apart! Gouge its eyes out!",
}
STRINGS.CROWSCYTHE_TALK.NEWMOON = {
    "The eyelid closes. Darkness is truth.",
    "The air tastes sweet... the flavor of void.",
    "Lord of shadows, whose life tonight?",
    "At the moon's blind spot, we are gods.",
}
STRINGS.CROWSCYTHE_TALK.NIGHTVISION_ON = {
    "Strip the mask. Stare into despair.",
    "Only black silhouettes remain.",
    "The world is bleeding. See the wound.",
}
STRINGS.CROWSCYTHE_TALK.NIGHTVISION_OFF = {
    "The blind are the happiest.",
    "Truth waits behind closed eyes.",
    "Close your eyes. It still watches.",
}
STRINGS.CROWSCYTHE_TALK.KILL_REGEN = {
    "Blood is bitter, but souls run hot.",
    "I stitch you up with black feathers. Mind the cost.",
    "Life is light as a single black plume.",
    "You kill. I harvest despair.",
    "The edge is burning. Next one!",
}
STRINGS.CROWSCYTHE_TALK.REJECT = {
    "You stink of moonlight. Leave!",
    "Want to test how sharp I cut flesh?",
    "Shadow recognizes only my contractor!",
    "Take your filthy hands away, before I shred you!",
}
STRINGS.CROWSCYTHE_TALK.REJECT_SHADOW = {
    "Hiss... do not force me!",
    "No! That one stands above.",
    "No! We'll be found!",
}
STRINGS.CROWSCYTHE_TALK.REJECT_SHADOW_STRONGGRIP = {
    "I cannot!",
    "Don't grip me! I'd never!",
    "Ahhhhhh!",
}

-- nature tools wand
STRINGS.NAMES.NATURETOOLSWAND = "Nature Tool Wand"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.NATURETOOLSWAND = "One wand to gather and work."
STRINGS.RECIPE_DESC.NATURETOOLSWAND = "A wand shaped from the force of nature."

-- repair lines
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES = STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES or {}
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.FULL = "It's new, no repair needed."
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.INVALID = "Maybe I should try a different material."
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.SUCCESS = "Power of the rose, repair complete!"
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.CROWSCYTHE_SUCCESS = {
    "Is this all you brought to feed me?",
    "You call this scrap a worthy offering?",
    "Bring a proper tribute next time, if you can.",
}

-- durability lines
STRINGS.ROSE_EQUIP_PACK_DURABILITY_LINES = STRINGS.ROSE_EQUIP_PACK_DURABILITY_LINES or {}
STRINGS.ROSE_EQUIP_PACK_DURABILITY_LINES.BROKEN_GENERIC = "It's broken."
STRINGS.ROSE_EQUIP_PACK_DURABILITY_LINES.CROWSCYTHE_BROKEN_OWNER = "Hey, keep working."
STRINGS.ROSE_EQUIP_PACK_DURABILITY_LINES.CROWSCYTHE_BROKEN_WEAPON = "I demand dark souls!"

-- water warning lines
STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES = STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES or {}
STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES.ROSEPARASOL_LOW_DURABILITY_5 = "Maybe I should find land."
STRINGS.ROSE_EQUIP_PACK_WATER_WARNING_LINES.ROSEPARASOL_LOW_DURABILITY_1 = "I'm going down!"

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
