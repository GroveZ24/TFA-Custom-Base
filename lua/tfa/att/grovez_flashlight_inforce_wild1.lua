if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Inforce WILD1 Weapon Integrated Lighting Device"
ATTACHMENT.ShortName = "APLc"
ATTACHMENT.Icon = "entities/grovez_flashlight_inforce_wild1.png"
ATTACHMENT.Description = {
	Color(255, 255, 50), "[+] Flashlight output: 500",
	Color(255, 255, 50), "[+] Flashlight distance: 315",
	Color(255, 255, 50), "[+] Flashlight beam intensity: 7500",
	Color(255, 50, 50), "[-] Ergonomics: -0.5",
	Color(255, 255, 255), "[=] Weight: +0.083"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["flashlight_aplc"] = {
			["active"] = true
		}
	},
	["Ergonomics"] = function(wep, val) return val - 0.5 end,
	["Weight"] = function(wep, val) return val + 0.083 end,
	["HasFlashlight"] = true,
	["FlashlightAttachment"] = 5,
	["FlashlightDistance"] = 315 * (3.28084 * 16),
	["FlashlightBrightness"] = 500 * 0.01,
	["FlashlightFOV"] = 7500 * 0.015,
	["FlashlightSoundToggleOn"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT"),
	["FlashlightSoundToggleOff"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT")
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

function ATTACHMENT:Attach(wep)
	wep.FlashlightDotMaterial = nil
	wep.FlashlightDotMaterial = Material("effects/tfa_grovez/flashlight_15")

	wep.ViewModelBoneMods["tag_flashlight_lightsource"].pos = wep.FlashlightLightsourcePos_APLc
	wep.ViewModelBoneMods["tag_flashlight_lightsource"].angle = wep.FlashlightLightsourceAng_APLc

	local owner = wep:GetOwner()

	if SERVER and IsValid(owner) and owner:IsPlayer() and owner:FlashlightIsOn() then
		owner:Flashlight(false)
	end
end

function ATTACHMENT:Detach(wep)
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