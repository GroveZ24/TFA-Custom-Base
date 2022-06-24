if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "1П87"
ATTACHMENT.ShortName = "ПК120"
ATTACHMENT.Icon = "entities/grovez_scope_pk120.png"
ATTACHMENT.Description = {
	Color(50, 255, 50), "[+] Zoom: +5%",
	Color(255, 50, 50), "[-] Ergonomics: -4",
	Color(255, 255, 255), "[=] Weight: +0.298"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["scope_pk120"] = {
			["active"] = true
		},
		["scope_pk120_lens"] = {
			["active"] = true
		}
	},
	["IronSightsPos"] = function(wep, val)
		return val + wep.SightOffset_PK120 or val
	end,
	["Secondary"] = {
		["IronFOV"] = function(wep, val)
			return val * 0.95
		end
	},
	["Ergonomics"] = function(wep, val) return val - 4 end,
	["Weight"] = function(wep, val) return val + 0.298 end,
	["ScopeVElement"] = "scope_pk120",
	["Reticle"] = "models/weapons/tfa_grovez/mods/scopes/scope_pk120/PK120_Reticle"
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end