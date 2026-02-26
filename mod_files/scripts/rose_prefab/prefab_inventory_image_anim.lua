local rose_prefab_tuning = require("rose_prefab/rose_prefab_tuning")

local inventory_image_anim = {}

local function stop_task(inst)
    if inst.equip_changeimg_task ~= nil then
        inst.equip_changeimg_task:Cancel()
        inst.equip_changeimg_task = nil
    end
end

local function init_inventory_image(inst, atlas_xml_name)
    inst.name_num = 1
    inst.inv_image_bg = {
        image = "1.tex",
        atlas = "images/frames/" .. atlas_xml_name .. ".xml",
    }
end

local function clamp_frame(current_frame, total_frame_count)
    if current_frame > total_frame_count then
        return ((current_frame - 1) % total_frame_count) + 1
    end
    return current_frame
end

---构建背包动图控制器，统一管理任务生命周期。
---@param config table|nil
---@return table
function inventory_image_anim.build_controller(config)
    local anim_config = rose_prefab_tuning.merge_inventory_anim(config)
    local enabled = anim_config.enabled and anim_config.atlas_xml_name ~= nil

    local function advance_frame(inst)
        local current_frame = tonumber(inst.name_num) or 1
        local next_frame = clamp_frame(current_frame + anim_config.step_len, anim_config.total_frame_count)

        inst.name_num = next_frame
        if inst.inv_image_bg == nil then
            init_inventory_image(inst, anim_config.atlas_xml_name)
        else
            inst.inv_image_bg.image = tostring(next_frame) .. ".tex"
            inst.inv_image_bg.atlas = "images/frames/" .. anim_config.atlas_xml_name .. ".xml"
        end

        inst:PushEvent("imagechange")
    end

    local controller = {}

    function controller.start(inst)
        if not enabled or inst == nil then
            return
        end

        if inst.equip_changeimg_task ~= nil then
            return
        end

        init_inventory_image(inst, anim_config.atlas_xml_name)
        inst.equip_changeimg_task = inst:DoPeriodicTask(anim_config.frame_interval, function(target)
            advance_frame(target)
        end)
    end

    function controller.stop(inst)
        if inst == nil then
            return
        end

        stop_task(inst)
    end

    function controller.cleanup(inst)
        if inst == nil then
            return
        end

        stop_task(inst)
        inst.name_num = nil
        inst.inv_image_bg = nil
    end

    return controller
end

return inventory_image_anim
