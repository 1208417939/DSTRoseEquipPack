local constants = require("rose_core/rose_constants")
local config_runtime = require("rose_core/rose_config_runtime")

local weapon_factory = {}

---为武器实体挂载统一的运行时组件，并注入配置
---@param inst table 武器实体
---@param weapon_def table 武器定义表
function weapon_factory.attach_runtime(inst, weapon_def)
    if inst.components[constants.RUNTIME_COMPONENT] == nil then
        inst:AddComponent(constants.RUNTIME_COMPONENT)
    end

    local runtime_config = config_runtime.build_weapon_config(weapon_def)
    inst.components[constants.RUNTIME_COMPONENT]:Setup(weapon_def, runtime_config)
end

return weapon_factory
