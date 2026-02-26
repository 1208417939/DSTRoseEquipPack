local weapon_ids = {
    "roseaxe",
    "rosegunflag",
    "rosescissors",
    "roseparasol",
    "rosefrostwand",
    "oceantrident",
    "crowscythe",
    "naturetoolswand"
}

local weapon_data_resolver = require("rose_core/rose_weapon_data_resolver")

for _, weapon_id in ipairs(weapon_ids) do
    local recipe_data = weapon_data_resolver.resolve_recipe_data(weapon_id)

    if recipe_data and recipe_data.ingredients and #recipe_data.ingredients > 0 then
        local ingredients = {}
        for _, material in ipairs(recipe_data.ingredients) do
            table.insert(ingredients, Ingredient(material[1], material[2]))
        end

        local recipe_config = {
            atlas = string.format("images/%s.xml", recipe_data.prefab_id),
            image = string.format("%s.tex", recipe_data.prefab_id),
        }

        if recipe_data.station_tag ~= nil then
            recipe_config.station_tag = recipe_data.station_tag
        end
        if recipe_data.nounlock == true then
            recipe_config.nounlock = true
        end

        AddRecipe2(weapon_id, ingredients, recipe_data.tech or TECH.MAGIC_TWO, recipe_config, { "WEAPONS" })
    end
end
