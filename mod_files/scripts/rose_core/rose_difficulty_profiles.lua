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
                repair = {
                    values = {
                        redgem = 250,
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
                repair = {
                    values = {
                        redgem = 250,
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
                repair = {
                    values = {
                        redgem = 250,
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
                repair = {
                    values = {
                        bluegem = 250,
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
                repair = {
                    values = {
                        bluegem = 350,
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
                repair = {
                    values = {
                        bluegem = 200,
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
                repair = {
                    values = {
                        nightmarefuel = 100,
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
                repair = {
                    values = {
                        flint = 100,
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
                base_damage_multiplier = 1.0,
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
                repair = {
                    values = {
                        redgem = 25,
                        purebrilliance = 150,
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
                repair = {
                    values = {
                        redgem = 25,
                        purebrilliance = 150,
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
                repair = {
                    values = {
                        redgem = 25,
                        purebrilliance = 150,
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
                repair = {
                    values = {
                        bluegem = 25,
                        purebrilliance = 150,
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
                max_uses = 300,
                repair = {
                    values = {
                        bluegem = 25,
                        opalpreciousgem = 200,
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
                repair = {
                    values = {
                        opalpreciousgem = 200,
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
                repair = {
                    values = {
                        horrorfuel = 200,
                        nightmarefuel = 25,
                    },
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
                repair = {
                    values = {
                        orangegem = 150,
                    },
                },
            },
        },
    },
}

return difficulty_profiles
