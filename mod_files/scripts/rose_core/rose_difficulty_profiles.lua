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
            recipe = {
                tech = TECH.MAGIC_THREE,
            },
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
                },
            },
            naturetoolswand = {
                recipe = {
                    ingredients = {
                        { "petals", 10 },
                        { "livinglog", 1 },
                        { "flint", 1 },
                    },
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
            recipe = {
                tech = TECH.LUNARFORGING_TWO,
                station_tag = "lunar_forge",
                nounlock = true,
            },
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
                    tech = TECH.SHADOWFORGING_TWO,
                    station_tag = "shadow_forge",
                    nounlock = true,
                },
            },
            naturetoolswand = {
                recipe = {
                    ingredients = {
                        { "orangeamulet", 5 },
                        { "livinglog", 2 },
                        { "petals", 20 },
                    },
                    tech = TECH.ANCIENT_FOUR,
                    station_tag = "ancient_station",
                    nounlock = false,
                },
            },
        },
    },
}

return difficulty_profiles
