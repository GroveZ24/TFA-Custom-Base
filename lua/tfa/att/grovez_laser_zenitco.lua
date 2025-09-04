if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Laser"
ATTACHMENT.ShortName = "M300C"
ATTACHMENT.Icon = "entities/grovez_flashlight_surefire_m300c_scout_black.png"
ATTACHMENT.Description = {
	Color(255, 255, 50), "[+] Flashlight output: 500",
	Color(255, 255, 50), "[+] Flashlight distance: 175",
	Color(255, 255, 50), "[+] Flashlight beam intensity: 7600",
	Color(255, 50, 50), "[-] Ergonomics: -3",
	Color(255, 255, 255), "[=] Weight: +0.116"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["laser_zenitco"] = {
			["active"] = true,
			["skin"] = 0
		}
	},
	["LaserSightAttachment"] = function(wep,stat) return wep.LaserSightModAttachment end,
	["LaserSightAttachmentWorld"] = function(wep,stat) return wep.LaserSightModAttachmentWorld or wep.LaserSightModAttachment end
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"


if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end