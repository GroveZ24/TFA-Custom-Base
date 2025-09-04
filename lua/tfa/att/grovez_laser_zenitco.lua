if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Zenitco Perst 5"
ATTACHMENT.ShortName = "ZP5"
ATTACHMENT.Icon = "entities/tfa_qmark.png"
ATTACHMENT.Description = {
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