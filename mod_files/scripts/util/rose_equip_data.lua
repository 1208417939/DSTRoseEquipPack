local equip_data = {
    crowscythe = {
        prefab_id = "crowscythe",
        base_damage = 15,
        attack_range = 2,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 200,
        dapperness = -20 / 60,
        light_preset = "purple",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = true,
                attack_radius = 6.5,
                aoe_damage_multiplier = 0.7,
                trigger_hit_count = 1,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = false,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = true,
                heal_percent = 5,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = true,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
            nightvision_toggle = {
                enabled = true,
                default_enabled = false,
                extra_sanity_drain_per_min = 10,
            },
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "crowscythe_merged_img_1722071134",
        },
    },
    naturetoolswand = {
        prefab_id = "naturetoolswand",
        base_damage = 17,
        attack_range = 2.5,
        walk_speed_multiplier = 1.25,
        planar_damage = 0,
        max_uses = 500,
        dapperness = 0,
        light_preset = "neutral",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = false,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
            collect = {
                enabled = true,
                radius = 20,
                collect_pickable = true,
                collect_crop = true,
                exclude_prefabs = {
                    flower = true,
                    flower_evil = true,
                },
                exclude_product_prefabs = {
                    petals = true,
                    petals_evil = true,
                    foliage = true,
                },
            },
        },

        tool_actions = {
            { action_id = "CHOP", effectiveness = 1, use_cost = 1 },
            { action_id = "MINE", effectiveness = 1, use_cost = 1 },
            { action_id = "DIG", effectiveness = 1, use_cost = 1 },
            { action_id = "HAMMER", effectiveness = 1, use_cost = 1 },
        },

        spell = {
            can_use_on_point = true,
            can_use_on_point_water = false,
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "naturetoolswand_merged_img_1722071134",
        },
    },
    oceantrident = {
        prefab_id = "oceantrident",
        base_damage = 30,
        attack_range = 1.8,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 200,
        dapperness = 0,
        light_preset = "cool",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = false,
                chance = 30,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = true,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.3,
                damage_multiplier = 1.5,
                max_health_bonus_percent = 0.2,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
            waterproof = {
                enabled = true,
                waterproof_percent = 80,
            },
            walk_on_water = {
                enabled = false,
            },
            fish_burst = {
                enabled = true,
                radius = 4,
                durability_cost = 5,
            },
        },

        spell = {
            can_use_on_point = false,
            can_use_on_point_water = true,
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "oceantrident_merged_img_1722071134",
        },
    },
    roseaxe = {
        prefab_id = "roseaxe",
        base_damage = 35,
        attack_range = 1,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 250,
        dapperness = 0,
        light_preset = "warm",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = true,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = true,
                max_health_damage_percent = 2.5,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
        },

        tool_actions = {
            { action_id = "CHOP" },
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "roseaxe_merged_img_1722071134",
        },
    },
    rosefrostwand = {
        prefab_id = "rosefrostwand",
        base_damage = 30,
        attack_range = 1.5,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 250,
        dapperness = 0,
        light_preset = "cool",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = true,
                chance = 30,
                coldness = 2,
            },
            stun = {
                enabled = false,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "rosefrostwand_merged_img_1722071134",
        },
    },
    rosegunflag = {
        prefab_id = "rosegunflag",
        base_damage = 30,
        attack_range = 1.5,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 250,
        dapperness = 0,
        light_preset = "warm",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = true,
                chance = 12,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = false,
                chance = 10,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = true,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "rosegunflag_merged_img_1722071134",
        },
    },
    roseparasol = {
        prefab_id = "roseparasol",
        base_damage = 25,
        attack_range = 1.5,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        dapperness = 0,
        light_preset = "cool",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = true,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 3,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 60,
                coldness = 2,
            },
            stun = {
                enabled = false,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = false,
                charge_chance = 0.2,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
            waterproof = {
                enabled = true,
                waterproof_percent = 100,
            },
            walk_on_water = {
                enabled = true,
                default_enabled = false,
                durability_cost_per_minute = 5,
            },
        },

        insulator = {
            enabled = true,
            mode = "summer",
            insulation = TUNING.INSULATION_LARGE,
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "roseparasol_merged_img_1722071134",
        },
    },
    rosescissors = {
        prefab_id = "rosescissors",
        base_damage = 30,
        attack_range = 1.2,
        walk_speed_multiplier = 1.25,
        planar_damage = 30,
        max_uses = 250,
        dapperness = 0,
        light_preset = "warm",

        abilities = {
            upgrade_by_gold = {
                enabled = false,
                accepted_prefab = "goldnugget",
            },
            critical = {
                enabled = false,
                min_chance = 5,
                max_chance = 30,
                chance_add_per_miss = 1,
                max_damage_multiplier = 4,
                min_damage_multiplier = 1.2,
                damage_multiplier_reduce_per_miss = 0.3,
            },
            aoe = {
                enabled = false,
                attack_radius = 4,
                aoe_damage_multiplier = 0.5,
                trigger_hit_count = 3,
                trigger_window_time = 5,
            },
            fire = {
                enabled = false,
                chance = 10,
                effect_duration = 5,
                tick_damage = 5,
                tick_period = 1,
            },
            ice = {
                enabled = false,
                chance = 20,
                coldness = 1,
            },
            stun = {
                enabled = false,
                chance = 8,
                stun_duration = 2,
            },
            kill_regen = {
                enabled = false,
                heal_percent = 1,
            },
            tri_circle = {
                enabled = false,
                max_health_damage_percent = 3,
            },
            combo = {
                enabled = false,
                max_combo_count = 5,
                combo_damage_multiplier = 0.05,
                combo_reset_time = 2,
            },
            behead = {
                enabled = false,
                health_percent_threshold = 0.2,
                damage_multiplier = 1.5,
            },
            giant_killer = {
                enabled = false,
                giant_health_threshold = 3000,
                health_percent_threshold = 0.9,
                damage_multiplier = 1.4,
            },
            hamstring = {
                enabled = true,
                charge_chance = 0.25,
                required_charge_count = 5,
                tick_damage = 8,
                check_period = 0.01,
                effect_duration = 10,
            },
        },

        sakura_particle = {
            enabled = false,
        },

        inventory_image_anim = {
            enabled = false,
            atlas_xml_name = "rosescissors_merged_img_1722071134",
        },
    },
}

return equip_data
