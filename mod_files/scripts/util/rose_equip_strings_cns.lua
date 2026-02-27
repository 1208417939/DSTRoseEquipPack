-- rose axe
STRINGS.NAMES.ROSEAXE = '玫瑰大斧'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEAXE = '用玫瑰精油保养？'
STRINGS.RECIPE_DESC.ROSEAXE = '拿起来也优雅。'

-- rose gun flag
STRINGS.NAMES.ROSEGUNFLAG = "玫瑰枪旗"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEGUNFLAG = "香气振奋人心。"
STRINGS.RECIPE_DESC.ROSEGUNFLAG = "高贵之旗，闪耀勇气。"

-- rose scissors
STRINGS.NAMES.ROSESCISSORS = "玫瑰剪刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSESCISSORS = "该修修我的花圃了。"
STRINGS.RECIPE_DESC.ROSESCISSORS = "巨大而锋利。"

-- rose parasol
STRINGS.NAMES.ROSEPARASOL = "玫瑰阳伞"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEPARASOL = "希望别太热。"
STRINGS.RECIPE_DESC.ROSEPARASOL = "行走在海面之上。"

-- rose frost wand
STRINGS.NAMES.ROSEFROSTWAND = "玫瑰霜杖"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEFROSTWAND = "散发着冰冷的气息。"
STRINGS.RECIPE_DESC.ROSEFROSTWAND = "冬日里的第一朵玫瑰。"

-- ocean trident
STRINGS.NAMES.OCEANTRIDENT = "海洋三叉戟"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OCEANTRIDENT = "向海而战。"
STRINGS.RECIPE_DESC.OCEANTRIDENT = "海面上的雷鸣之矛。"

-- crow scythe
STRINGS.NAMES.CROWSCYTHE = "乌鸦镰刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CROWSCYTHE = "刀刃中仿佛回响着黑羽的低语。"
STRINGS.RECIPE_DESC.CROWSCYTHE = "让乌鸦回应每一次挥舞。"

-- nature tools wand
STRINGS.NAMES.NATURETOOLSWAND = "自然法杖"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.NATURETOOLSWAND = "一杖在手，采集与作业都能完成。"
STRINGS.RECIPE_DESC.NATURETOOLSWAND = "自然之力凝成的工具法杖。"

-- repair lines
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES = STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES or {}
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.FULL = "是新的，不需要修补。"
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.INVALID = "也许我该换个材料。"
STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES.SUCCESS = "玫瑰之力，修复成功！"

local function setup_useitem_action_text_cns()
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

    useitem_strings.ROSEPARASOL_OPEN = "打开"
    useitem_strings.ROSEPARASOL_CLOSE = "关闭"
    useitem_strings.CROWSCYTHE_OPEN = "打开"
    useitem_strings.CROWSCYTHE_CLOSE = "关闭"

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

setup_useitem_action_text_cns()
