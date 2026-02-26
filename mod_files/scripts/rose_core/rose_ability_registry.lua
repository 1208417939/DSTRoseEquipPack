local ability_registry = {}
local registered_paths = {}

function ability_registry.Register(ability_name, module_path)
    registered_paths[ability_name] = module_path
end

function ability_registry.Resolve(ability_name)
    local module_path = registered_paths[ability_name]
    if module_path == nil then
        return nil
    end

    return require(module_path)
end

function ability_registry.List()
    local names = {}
    for ability_name in pairs(registered_paths) do
        table.insert(names, ability_name)
    end
    table.sort(names)
    return names
end

return ability_registry
