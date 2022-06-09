DEFINE_BASECLASS("tfa_gun_base")

----[[CUSTOM STATS]]----

SWEP.HasFlashlight = false

----[[REMOVE SPRINT BOB COMPLETELY]]----

function SWEP:SprintBob(pos, ang, intensity, origPos, origAng)
	return pos, ang
end

----[[DRAW SINGLE RETICLE]]----

function DrawSingleReticle()
	if TFA.INS2 and TFA.INS2.DrawHoloSight then
		local drawFunc = TFA.INS2.DrawHoloSight

		return function(wep, p, a, s)
			local reticle = wep:GetStat("Reticle", {})
			if not reticle then return end

			local activeelem = wep:GetStat("ScopeVElement")
			if not activeelem then return end

			local result = reticle
			if not result then return end

			drawFunc(wep, result, activeelem, p, a, s)
		end
	end

	return nil
end

----[[ADS RELOAD FOV FIX]]---- 

local function l_Lerp(v, f, t)
	return f + (t - f) * v
end

function SWEP:TranslateFOV(fov)
	local self2 = self:GetTable()

	self2.LastTranslatedFOV = fov

	local retVal = hook.Run("TFA_PreTranslateFOV", self,fov)

	if retVal then return retVal end

	self:CorrectScopeFOV()

	local nfov = l_Lerp(self:GetIronSightsProgress(), fov, fov * math.min(self:GetStatL("Secondary.OwnerFOV") / 90, 1))
	local ret = l_Lerp(self2.SprintProgressUnpredicted or self:GetSprintProgress(), nfov, nfov + self2.SprintFOVOffset)

	if self:OwnerIsValid() and not self2.IsMelee then
		local vpa = self:GetOwner():GetViewPunchAngles()

		ret = ret + math.abs(vpa.p) / 4 + math.abs(vpa.y) / 4 + math.abs(vpa.r) / 4
	end

	ret = hook.Run("TFA_TranslateFOV", self,ret) or ret

	return ret
end

----[[SIGHTS POSE PARAMETER]]----

function SWEP:SightsPoseParameter()
	local VM = LocalPlayer():GetViewModel() or NULL
	local IronSightProgress = LocalPlayer():GetActiveWeapon().IronSightsProgress
	if VM:IsValid() then
		self.OwnerViewModel:SetPoseParameter("sights", IronSightProgress)
		self.OwnerViewModel:InvalidateBoneCache()
	end
end

----[[FREE VIEWMODEL]]----

local freevm_var = CreateConVar("cl_tfa_debug_freevm", 0, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE})

hook.Add("CalcViewModelView", "TFA_Debug_FreeVM", function(w, v, op, oa, p, a)
	if freevm_var:GetFloat() == 1 then
		if not fp then
			fp, fa = Vector(p), Angle(a)
		end

		p:Set(fp)
		a:Set(fa)
	end
end)

----[[C_MENU SOUNDS]]----

if CLIENT then
	function SWEP:OnCustomizationOpen()
		self:EmitSound("TFA_GROVEZ.SHARED.MENU_ENTER")
	end

	function SWEP:OnCustomizationClose()
		self:EmitSound("TFA_GROVEZ.SHARED.MENU_EXIT")
	end
end

----[[FLASHLIGHT STUFF]]----

hook.Add("PlayerSwitchFlashlight", "TFA_Disable_Flashlight", function(ply, enabled)
	return ply:GetActiveWeapon().HasFlashlight
end)

----[[STAT CACHE BLACKLIST]]----

SWEP.StatCache_Blacklist = {
	--Used for dynamic stats, empty for now
}

----[[THINK]]----

function SWEP:Think(...)
	if CLIENT then
		self:SightsPoseParameter()
	end

	return BaseClass.Think(self, ...)
end

----[[THINK2: ELECTRIC BOOGALOO]]----

function SWEP:Think2(...)
	--Used for dynamic stats, empty for now
	
	return BaseClass.Think2(self, ...)
end

--https://sun9-85.userapi.com/s/v1/ig2/n_WKNsnSh8wVwBFfDfMJrV6wOM1jj2VRLFWnQ_2YkHz2F2bZYe7rqE9aiY8lr56wV7sf0EmzV2I8SE8Nl8bKAbfc.jpg?size=800x450&quality=96&type=album