if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "1П87"
ATTACHMENT.ShortName = "ПК120"
ATTACHMENT.Icon = "entities/grovez_scope_pk120.png"
ATTACHMENT.Description = {}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["scope_pk120"] = {
			["active"] = true,
		},
		["scope_pk120_lens"] = {
			["active"] = true,
		},
	},
	["IronSightsPos"] = function(wep, val)
		return val + Vector(0.145, 0, -1.5)
	end,
	["Secondary"] = {
		["IronFOV"] = function(wep, val)
			return val * 0.95
		end
	},
	["SightVElement"] = "scope_pk120",
	["Reticle"] = "models/weapons/tfa_grovez/mods/scopes/pk120/reticle"
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end