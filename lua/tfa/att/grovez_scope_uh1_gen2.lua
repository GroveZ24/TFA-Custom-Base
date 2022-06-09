if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Vortex AMG UH-1 Gen II"
ATTACHMENT.ShortName = "UH-1"
ATTACHMENT.Icon = "entities/grovez_scope_uh1_gen2.png"
ATTACHMENT.Description = {}

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["scope_uh1_gen2"] = {
			["active"] = true
		},
		["scope_uh1_gen2_lens"] = {
			["active"] = true
		}
	},
	["IronSightsPos"] = function(wep, val)
		return val + Vector(0.11, 0, -1.22)
	end,
	["Secondary"] = {
		["IronFOV"] = function(wep, val)
			return val * 0.9
		end
	},
	["ScopeVElement"] = "scope_uh1_gen2",
	["Reticle"] = "models/weapons/tfa_grovez/mods/scopes/scope_uh1_gen2/UH1_Reticle"
}

ATTACHMENT.AttachSound = "TFA_GROVEZ.SHARED.MENU_MOD_SELECT"
ATTACHMENT.DetachSound = "TFA_GROVEZ.SHARED.MENU_MOD_DESELECT"

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end