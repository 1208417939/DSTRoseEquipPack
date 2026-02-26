local weapon_def = {
    id = "rose_new_weapon",
    config_key_prefix = "rose_new_weapon",
    ability_defaults = {
        combo = {
            enabled = true,
            max_combo_count = 5,
            combo_damage_multiplier = 0.05,
            combo_reset_time = 2,
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
        tri_circle = {
            enabled = true,
            max_health_damage_percent = 3,
        },
        aoe = {
            enabled = false,
            attack_radius = 4,
            aoe_damage_multiplier = 0.5,
            trigger_hit_count = 3,
            trigger_window_time = 5,
        },
        waterproof = {
            enabled = false,
            waterproof_percent = 70,
        },
        walk_on_water = {
            enabled = false,
        },
    },
    ability_order = {
        "combo",
        "critical",
        "tri_circle",
        "aoe",
        "waterproof",
        "walk_on_water",
    },
    ability_modules = {
        combo = "rose_abilities/ability_combo",
        critical = "rose_abilities/ability_critical",
        tri_circle = "rose_abilities/ability_tri_circle",
        aoe = "rose_abilities/ability_aoe",
        waterproof = "rose_abilities/ability_waterproof",
        walk_on_water = "rose_abilities/ability_walk_on_water",
    },
    equip = {
        walk_speed_multiplier = 1.0,
        dapperness = 0,
    },
    combat = {
        base_damage = 50,
        range = 2,
        planar_damage = 10,
    },
    progression = {
        growth_curve = {
            exponent = 1.2,
            scale = 10,
            precision = 0.1,
        },
    },
    recipe = {
        { "goldnugget", 2 },
        { "redgem", 1 },
    },
}

return weapon_def
