if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Surefire M300C (Scout mount, Black)"
ATTACHMENT.ShortName = "M300C"
ATTACHMENT.Icon = "entities/grovez_flashlight_surefire_m300c_scout_black.png"
ATTACHMENT.Description = {}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["flashlight_m300c_scout_black"] = {
			["active"] = true
		}
	},
	["HasFlashlight"] = true,
	["FlashlightAttachment"] = 1,
	["FlashlightDistance"] = 1500,
	["FlashlightBrightness"] = 10,
	["FlashlightFOV"] = 110,
	["FlashlightSoundToggleOn"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT"),
	["FlashlightSoundToggleOff"] = Sound("TFA_GROVEZ.SHARED.FLASHLIGHT")
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

function ATTACHMENT:Attach(wep)
	wep.FlashlightDotMaterial = nil
	wep.FlashlightDotMaterial = Material("effects/tfa_grovez/flashlight_10")
end

function ATTACHMENT:Detach(wep)
	wep.FlashlightDotMaterial = nil
	wep.FlashlightDotMaterial = Material("effects/flashlight001")
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end