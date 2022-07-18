if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Surefire M300C (HSP Thorntail mount, Tan)"
ATTACHMENT.ShortName = "M300C"
ATTACHMENT.Icon = "entities/grovez_flashlight_surefire_m300c_thorntail_tan.png"
ATTACHMENT.Description = {
	Color(255, 255, 50), "[+] Flashlight output: 500",
	Color(255, 255, 50), "[+] Flashlight distance: 175",
	Color(255, 255, 50), "[+] Flashlight beam intensity: 7600",
	Color(255, 50, 50), "[-] Ergonomics: -1",
	Color(255, 255, 255), "[=] Weight: +0.102"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["flashlight_m300c_thorntail"] = {
			["active"] = true,
			["skin"] = 1
		}
	},
	["Ergonomics"] = function(wep, val) return val - 1 end,
	["Weight"] = function(wep, val) return val + 0.102 end,
	["FlashlightAttachment"] = 5,
	["FlashlightDistance"] = 175 * (3.28084 * 16),
	["FlashlightBrightness"] = 500 * 0.01,
	["FlashlightFOV"] = 7600 * 0.015,
	["FlashlightSoundToggleOn"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT"),
	["FlashlightSoundToggleOff"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT")
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

function ATTACHMENT:Attach(wep)
	wep.HasFlashlight = true

	wep.FlashlightDotMaterial = nil
	wep.FlashlightDotMaterial = Material("effects/tfa_grovez/flashlight_10")

	wep.ViewModelBoneMods["tag_flashlight_lightsource"].pos = wep.FlashlightLightsourcePos_M300CThorntail
	wep.ViewModelBoneMods["tag_flashlight_lightsource"].angle = wep.FlashlightLightsourceAng_M300CThorntail

	local owner = wep:GetOwner()

	if SERVER and IsValid(owner) and owner:IsPlayer() and owner:FlashlightIsOn() then
		owner:Flashlight(false)
	end
end

function ATTACHMENT:Detach(wep)
	wep.HasFlashlight = false

	wep.FlashlightDotMaterial = nil
	wep.FlashlightDotMaterial = Material("effects/flashlight001")

	wep.ViewModelBoneMods["tag_flashlight_lightsource"].pos = wep.FlashlightLightsourcePos
	wep.ViewModelBoneMods["tag_flashlight_lightsource"].angle = wep.FlashlightLightsourceAng

	if wep:GetFlashlightEnabled() then
		wep:ToggleFlashlight(false)
	end
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end