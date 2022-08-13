if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Leupold Carbine Optic"
ATTACHMENT.ShortName = "LCO"
ATTACHMENT.Icon = "entities/grovez_scope_lco.png"
ATTACHMENT.Description = {
	Color(50, 255, 50), "[+] Zoom: +5%",
	Color(255, 50, 50), "[-] Ergonomics: -4",
	Color(255, 255, 255), "[=] Weight: +0.270"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["scope_lco"] = {
			["active"] = true
		},
		["scope_lco_lens"] = {
			["active"] = true
		}
	},
	["IronSightsPos"] = function(wep, val)
		return val + wep.SightOffset_LCO or val
	end,
	["Secondary"] = {
		["IronFOV"] = function(wep, val)
			return val * 0.95
		end
	},
	["Ergonomics"] = function(wep, val) return val - 4 end,
	["Weight"] = function(wep, val) return val + 0.270 end,
	["ScopeVElement"] = "scope_lco",
	["Reticle"] = "models/weapons/tfa_grovez/mods/scopes/scope_lco/LCO_Reticle"
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end