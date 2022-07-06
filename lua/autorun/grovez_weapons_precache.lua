hook.Add("InitPostEntity", "grovez_weapon_precacher", function()
	for _, SWEP in ipairs(weapons.GetList()) do
		if SWEP.ClassName and weapons.IsBasedOn(SWEP.ClassName, "tfa_custom_base") then
			util.PrecacheModel(SWEP.ViewModel)
			print("Precached: " .. SWEP.ViewModel)
		end
	end
end)