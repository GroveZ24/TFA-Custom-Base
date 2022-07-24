if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Aimpoint Micro T-2 (AMM Mount)"
ATTACHMENT.ShortName = "T-2"
ATTACHMENT.Icon = "entities/grovez_scope_t2_short.png"
ATTACHMENT.Description = {
	Color(50, 255, 50), "[+] Zoom: +2.5%",
	Color(255, 50, 50), "[-] Ergonomics: -3",
	Color(255, 255, 255), "[=] Weight: +0.130"
}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["scope_t2_short"] = {
			["active"] = true
		},
		["scope_t2_short_lens"] = {
			["active"] = true
		}
	},
	["IronSightsPos"] = function(wep, val)
		return val + wep.SightOffset_T2_Short or val
	end,
	["Secondary"] = {
		["IronFOV"] = function(wep, val)
			return val * 0.975
		end
	},
	["Ergonomics"] = function(wep, val) return val - 3 end,
	["Weight"] = function(wep, val) return val + 0.130 end,
	["ScopeVElement"] = "scope_t2_short",
	["Reticle"] = "models/weapons/tfa_grovez/mods/scopes/scope_micro_t2/Micro_T2_Reticle"
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end