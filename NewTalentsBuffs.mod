return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NewTalentsBuffs` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("NewTalentsBuffs", {
			mod_script       = "scripts/mods/NewTalentsBuffs/NewTalentsBuffs",
			mod_data         = "scripts/mods/NewTalentsBuffs/NewTalentsBuffs_data",
			mod_localization = "scripts/mods/NewTalentsBuffs/NewTalentsBuffs_localization",
		})
	end,
	packages = {
		"resource_packages/NewTalentsBuffs/NewTalentsBuffs",
	},
}
