local LUNAR_FORGE_RECIPE = {
    tech = TECH.LUNARFORGING_TWO,
    station_tag = "lunar_forge",
    nounlock = true,
}

local SHADOW_FORGE_RECIPE = {
    tech = TECH.SHADOWFORGING_TWO,
    station_tag = "shadow_forge",
    nounlock = true,
}

local ANCIENT_STATION_UNLOCK_RECIPE = {
    tech = TECH.ANCIENT_FOUR,
    station_tag = "ancient_station",
    nounlock = false,
}

local difficulty_profiles = {
    newbie = {
        defaults = {
            equip = {
                light_enabled = true,
                speed_bonus_enabled = true,
            },
            combat = {
                base_damage_multiplier = 1.0,
            },
            recipe = LUNAR_FORGE_RECIPE,
        },
        weapon_overrides = {
            roseaxe = {
                recipe = {
                    ingredients = {
                        { "goldenaxe", 1 },
                        { "petals", 20 },
                        { "redgem", 1 },
                    },
                },
            },
            rosegunflag = {
                recipe = {
                    ingredients = {
                        { "spear", 1 },
                        { "silk", 10 },
                        { "redgem", 1 },
                    },
                },
            },
            rosescissors = {
                recipe = {
                    ingredients = {
                        { "razor", 1 },
                        { "petals", 20 },
                        { "redgem", 1 },
                    },
                },
            },
            rosefrostwand = {
                recipe = {
                    ingredients = {
                        { "icestaff", 1 },
                        { "petals", 20 },
                    },
                },
            },
            roseparasol = {
                recipe = {
                    ingredients = {
                        { "umbrella", 1 },
                        { "petals", 20 },
                        { "bluegem", 1 },
                    },
                },
            },
            oceantrident = {
                recipe = {
                    ingredients = {
                        { "goldenpitchfork", 1 },
                        { "petals", 20 },
                        { "bluegem", 1 },
                    },
                },
            },
            crowscythe = {
                recipe = {
                    ingredients = {
                        { "crow", 1 },
                        { "batbat", 1 },
                    },
                    tech = SHADOW_FORGE_RECIPE.tech,
                    station_tag = SHADOW_FORGE_RECIPE.station_tag,
                    nounlock = SHADOW_FORGE_RECIPE.nounlock,
                },
            },
            naturetoolswand = {
                recipe = {
                    ingredients = {
                        { "petals", 10 },
                        { "livinglog", 1 },
                        { "flint", 1 },
                    },
                    tech = ANCIENT_STATION_UNLOCK_RECIPE.tech,
                    station_tag = ANCIENT_STATION_UNLOCK_RECIPE.station_tag,
                    nounlock = ANCIENT_STATION_UNLOCK_RECIPE.nounlock,
                },
            },
        },
    },
    vanilla = {
        defaults = {
            equip = {
                light_enabled = false,
                speed_bonus_enabled = false,
            },
            combat = {
                base_damage_multiplier = 1.1,
            },
            recipe = LUNAR_FORGE_RECIPE,
        },
        weapon_overrides = {
            roseaxe = {
                recipe = {
                    ingredients = {
                        { "goldenaxe", 1 },
                        { "petals", 20 },
                        { "purebrilliance", 3 },
                    },
                },
            },
            rosegunflag = {
                recipe = {
                    ingredients = {
                        { "spear", 1 },
                        { "silk", 10 },
                        { "purebrilliance", 3 },
                    },
                },
            },
            rosescissors = {
                recipe = {
                    ingredients = {
                        { "razor", 1 },
                        { "petals", 20 },
                        { "purebrilliance", 3 },
                    },
                },
            },
            rosefrostwand = {
                recipe = {
                    ingredients = {
                        { "icestaff", 1 },
                        { "petals", 20 },
                        { "purebrilliance", 3 },
                    },
                },
            },
            roseparasol = {
                recipe = {
                    ingredients = {
                        { "livinglog", 1 },
                        { "eyebrellahat", 3 },
                        { "petals", 20 },
                    },
                },
            },
            oceantrident = {
                recipe = {
                    ingredients = {
                        { "livinglog", 1 },
                        { "trident", 1 },
                        { "petals", 20 },
                    },
                },
            },
            crowscythe = {
                recipe = {
                    ingredients = {
                        { "batbat", 1 },
                        { "crow", 1 },
                        { "horrorfuel", 2 },
                    },
                    tech = SHADOW_FORGE_RECIPE.tech,
                    station_tag = SHADOW_FORGE_RECIPE.station_tag,
                    nounlock = SHADOW_FORGE_RECIPE.nounlock,
                },
            },
            naturetoolswand = {
                recipe = {
                    ingredients = {
                        { "orangeamulet", 5 },
                        { "livinglog", 2 },
                        { "petals", 20 },
                    },
                    tech = ANCIENT_STATION_UNLOCK_RECIPE.tech,
                    station_tag = ANCIENT_STATION_UNLOCK_RECIPE.station_tag,
                    nounlock = ANCIENT_STATION_UNLOCK_RECIPE.nounlock,
                },
            },
        },
    },
}

return difficulty_profiles
