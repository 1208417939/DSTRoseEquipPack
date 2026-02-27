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
STRINGS.CROWSCYTHE_TALK = STRINGS.CROWSCYTHE_TALK or {}
STRINGS.CROWSCYTHE_TALK.DUSK_NIGHT = {
    "日落了。大地在流血。",
    "那颗大眼球又在天上发呆了。",
    "嘘……黑暗在生长。",
    "你的影子说，它受够你了。",
    "靠着营火发抖的鹌鹑。",
    "大星星眨眼，理智在下坠。",
}
STRINGS.CROWSCYTHE_TALK.GROUND = {
    "泥土里有蝼蚁的臭味。",
    "别把我丢在白光的视线里！",
    "我在土里听到了远古哀嚎。",
    "除了契约者，谁也别碰我！",
}
STRINGS.CROWSCYTHE_TALK.FULLMOON = {
    "大眼球疯了，好刺眼……",
    "月光是挤出的脓水。恶心。",
    "瞪那么大也是个瞎子。",
    "割破白光！挖出它的眼珠！",
}
STRINGS.CROWSCYTHE_TALK.NEWMOON = {
    "眼睑合上了。黑暗即真理。",
    "空气变甜了……虚无的味道。",
    "影之主，今夜带走谁的命？",
    "在月之盲点，我们即是神。",
}
STRINGS.CROWSCYTHE_TALK.NIGHTVISION_ON = {
    "撕开伪装，直视绝望。",
    "到处都是漆黑的剪影。",
    "世界在流血，看清伤口吧。",
}
STRINGS.CROWSCYTHE_TALK.NIGHTVISION_OFF = {
    "盲瞎的人最幸福。",
    "真相就在合眼后的漆黑里。",
    "闭上眼，它也还在看你。",
}
STRINGS.CROWSCYTHE_TALK.KILL_REGEN = {
    "血是苦的，但灵魂很烫。",
    "用黑羽缝补你，代价是理智。",
    "生命轻得像一根黑羽毛。",
    "你斩杀，我回收绝望。",
    "刃口在发烫！下一个！",
}
STRINGS.CROWSCYTHE_TALK.REJECT = {
    "你身上有月亮的臭味。滚！",
    "想试试我切肉的锋利吗？",
    "暗影只认得我的契约主！",
    "拿开脏手！把你剪碎喂影子！",
}
STRINGS.CROWSCYTHE_TALK.REJECT_SHADOW = {
    "嘶——别逼我！",
    "不行！那是更高的……！",
    "不！会被……发现！",
}
STRINGS.CROWSCYTHE_TALK.REJECT_SHADOW_STRONGGRIP = {
    "别！放开我！",
    "不！不要！强握！我不敢……！",
    "啊啊啊！",
}

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
