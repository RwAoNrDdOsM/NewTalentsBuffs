local mod = get_mod("NewTalentsBuffs")

local function is_local(unit)
    local player = Managers.player:owner(unit)

    return player and not player.remote
end
local function is_in_inn()
    local level_transition_handler = Managers.state.game_mode.level_transition_handler
    local level_key = level_transition_handler:get_current_level_keys()
    local is_in_inn = level_key == "inn_level"
    return is_in_inn
end

-- Get Buff on Talent Selected
mod:add_talent("bw_scholar", 1, 1, "rwaon_sienna_scholar_reduced_spread", {
    num_ranks = 1,
    icon = "sienna_scholar_reduced_spread",
    description_values = {
        {
            value_type = "percent",
            value = -0.4
        }
    },
    buffs = {
        "rwaon_sienna_scholar_reduced_spread"
    },
})

-- Localizes Text, first is the talent name, second is locazised name, third is localized description
mod:add_talent_text("rwaon_sienna_scholar_reduced_spread", "Focusing Lens", "Reduced ranged attack spread by %g%%.")

-- Buff that changes Stat Buffs
mod:add_talent_buff_template("bright_wizard", "rwaon_sienna_scholar_reduced_spread", {
    multiplier = -0.4,
    stat_buff = "reduced_spread",
})

-- Talent to check in other code
mod:add_talent("bw_scholar", 6, 3, "rwaon_sienna_scholar_increased_speed", {
    num_ranks = 1,
    buffer = "both",
    icon = "sienna_scholar_activated_ability_cooldown",
    description_values = {
        {
            value = 10
        },
        {
            value_type = "percent",
            value = 0.15
        }
    },
    requirements = {},
    buffs = {},
    buff_data = {}
})

-- Localizes Text, first is the talent name, second is locazised names in a table, third is localized description in a table (French is translated using Google Translate)
mod:add_talent_text("rwaon_sienna_scholar_increased_speed", {
    en = "Fiery Blood",
    fr = "Sang De Feu",
}, {
    en = "The Burning Head now grants %i seconds of %g%% increase movement and attack speed.",
    fr = "La tête ardente octroie désormais %i secondes de %g%% d'augmentation de la vitesse de déplacement et d'attaque.",
})

-- Buff that applies movement and attack speed Stat Buffs for 10 seconds with effects and sounds
mod:add_talent_buff_template("bright_wizard", "rwaon_sienna_scholar_increased_speed", {
    {
        apply_buff_func = "apply_movement_buff",
        multiplier = 1.15,
        icon = "sienna_scholar_activated_ability_cooldown",
        refresh_durations = true,
        remove_buff_func = "remove_movement_buff",
        duration = 10,
        dormant = false,
        path_to_movement_setting_to_modify = {
            "move_speed"
        }
    },
    {
        multiplier = 0.15,
        refresh_durations = true,
        duration = 10,
        stat_buff = "attack_speed"
    },
}, {
    activation_effect = "fx/screenspace_potion_03",
    deactivation_sound = "hud_gameplay_stance_deactivate",
    activation_sound = "hud_gameplay_stance_tank_activate",
})

-- Checks if the client has the required talent, if so adds the buff to the client
mod:hook_safe(ActionCareerBWScholar, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	local talent_extension = self.talent_extension
	local owner_unit = self.owner_unit

    if talent_extension:has_talent("rwaon_sienna_scholar_embodiment_of_aqshy", "bright_wizard", true) then
        mod:add_buff(owner_unit, "rwaon_sienna_scholar_embodiment_of_aqshy_overcharge")
	end	

    if talent_extension:has_talent("rwaon_sienna_scholar_increased_speed", "bright_wizard", true) then
        mod:add_buff(owner_unit, "rwaon_sienna_scholar_increased_speed")
	end	
end)

-- Another Talent to check in other code
mod:add_talent("bw_scholar", 6, 1, "rwaon_sienna_scholar_embodiment_of_aqshy", {
    description_values = {
        { 
            value = 3 
        },
        { 
            value = 10 
        },
    },
    icon = "sienna_scholar_activated_ability_dump_overcharge",
    buffs = {},
})
mod:add_talent_text("rwaon_sienna_scholar_embodiment_of_aqshy", "Embodiment of Aqshy", "The Burning Head now grants an overcharge reduction of %i for every hit, for the next %i seconds.")

-- A buff where if the event happens "on_hit", it will trigger the buff's function
mod:add_talent_buff_template("bright_wizard", "rwaon_sienna_scholar_embodiment_of_aqshy_overcharge", {
    duration = 10,
    refresh_durations = true,
    max_stacks = 1,
    event_buff = true,
    event = "on_hit",
    icon = "sienna_scholar_activated_ability_dump_overcharge",
    bonus = 3,
    buff_func = "rwaon_sienna_scholar_embodiment_of_aqshy_overcharge",
})

-- Adds a proc funtion which should be the same name a the buff function
mod:add_proc_function("rwaon_sienna_scholar_embodiment_of_aqshy_overcharge", function (player, buff, params)
    local player_unit = player.player_unit

    if not is_local(player_unit) then
        return
    end
    
    local hit_unit = params[1]
    local attack_type = params[2]
    local hit_zone_name = params[3]
    local target_number = params[4]
    local buff_type = params[5]
    local is_critical = params[6]  

    if attack_type == "projectile" and buff_type == "ULTIMATE" then
        return
    end

    if Unit.alive(player_unit) then
        local overcharge_amount = buff.bonus
        local overcharge_extension = ScriptUnit.extension(player_unit, "overcharge_system")

        if overcharge_extension then
            overcharge_extension:remove_charge(overcharge_amount)
        end
    end
end)