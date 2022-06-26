DEFINE_BASECLASS("tfa_gun_base")

----[[CUSTOM STATS]]----

SWEP.Ergonomics = 10

----[[EVENT TABLE: MAG DISCARD]]----

function SWEP:TFAMagDiscard()
	if SERVER then
		if self.Shotgun == true then return end

		if self:Clip1() >= 1 and self:GetStat("Akimbo") and (not self:GetStat("DisableChambering")) then
			if self:Clip1() >= 2 then
				self:SetClip1(2)
			else
				self:SetClip1(1)
			end
		elseif self:Clip1() >= 1 and self:GetStat("Akimbo") and self:GetStat("DisableChambering") then
			self:SetClip1(0)
		elseif self:Clip1() >= 1 and (not self:GetStat("DisableChambering")) then
			self:SetClip1(1)
		else
			self:SetClip1(0)
		end
	end
end

----[[EVENT TABLE: MAG DROP]]----

SWEP.MagImpactSounds = {
	"physics/metal/weapon_impact_hard1.wav",
	"physics/metal/weapon_impact_hard2.wav",
	"physics/metal/weapon_impact_hard3.wav"
}
SWEP.MagModel = "models/props_junk/CinderBlock01a.mdl"
SWEP.MagBodygroups = "000"
SWEP.MagSkin = 0
SWEP.MagDropSrcForward = 0
SWEP.MagDropSrcRight = 0
SWEP.MagDropSrcUp = 0
SWEP.MagDropAng = Angle(0, 0, 0)
SWEP.MagYeetVelocityForward = 0
SWEP.MagYeetVelocityRight = 0
SWEP.MagYeetVelocityUp = 0
SWEP.MagAngleVelocity = Vector(math.random(-750, 750), math.random(-750, 750), math.random(-750, 750))
SWEP.MagRemovalTimer = 60

function SWEP:TFAMagDrop()
	if SERVER then
		if not self.MagModel then return end

		local ply = self:GetOwner()
		local mag = ents.Create("tfa_droppedmag")

		if mag then
			mag.Model = self.MagModel
			mag.Bodygroups = self.MagBodygroups
			mag.TextureGroup = self.MagSkin
			mag.ImpactSounds = self.MagImpactSounds
			mag.RemovalTimer = self.MagRemovalTimer
			mag:SetPos(ply:GetShootPos() + ply:EyeAngles():Forward() * self.MagDropSrcForward + ply:EyeAngles():Right() * self.MagDropSrcRight + ply:EyeAngles():Up() * self.MagDropSrcUp)
			mag:SetAngles(ply:EyeAngles() + self.MagDropAng)
			mag:SetOwner(ply)
			mag:Spawn()

			local phys = mag:GetPhysicsObject()

			if IsValid(phys) then
				phys:SetVelocity(ply:GetVelocity() + ply:GetAimVector() + ply:EyeAngles():Forward() * self.MagYeetVelocityForward + ply:EyeAngles():Right() * self.MagYeetVelocityRight + ply:EyeAngles():Up() * self.MagYeetVelocityUp)
				phys:AddAngleVelocity(self.MagAngleVelocity)
			end
		end
	end
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

----[[MOVEMENT RELATED]]----

SWEP.CanReloadWhileSprinting = false

hook.Add("StartCommand", "TFA_Disable_Sprint", function(ply, cmd)
	local wep = ply:GetActiveWeapon()

	if ply:IsNPC() then return end
	if not wep.IsTFAWeapon then return end
	if not ply:Alive() then return end
	if wep.CanReloadWhileSprinting then return end

	local stat = wep:GetStatus()

	if stat ~= TFA.Enum.STATUS_IDLE then
		cmd:RemoveKey(IN_SPEED)
	end
end)

----[[JUMP ANIMS]]----

if SERVER then
	util.AddNetworkString("TFA_HasLanded")
	util.AddNetworkString("TFA_HasJumped")

	hook.Add("OnPlayerHitGround", "TFA_Landing_Anim", function(ply, inWater, onFloater, speed)
		net.Start("TFA_HasLanded")
		net.Send(ply)
	end)

	hook.Add("PlayerTick", "TFA_Jumping_Anim", function(ply)
		if IsValid(ply) and ply:Alive() then 
			if ply:KeyPressed(IN_JUMP) and ply:OnGround() then
				net.Start("TFA_HasJumped")
				net.Send(ply)
			end
		end
	end)
end

----[[FLASHLIGHT]]----

SWEP.HasFlashlight = false

hook.Add("PlayerSwitchFlashlight", "TFA_Disable_Flashlight", function(ply, enabled)
	return ply:GetActiveWeapon().HasFlashlight
end)

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

----[[SIGHTS POSE PARAMETER]]----

function SWEP:SightsPoseParameter()
	local VM = LocalPlayer():GetViewModel() or NULL
	local IronSightProgress = LocalPlayer():GetActiveWeapon().IronSightsProgress

	if VM:IsValid() then
		self.OwnerViewModel:SetPoseParameter("sights", IronSightProgress)
		self.OwnerViewModel:InvalidateBoneCache()
	end
end

----[[STAT CACHE BLACKLIST]]----

SWEP.StatCache_Blacklist = {
	["IronSightTime"] = true,
	["MoveSpeed"] = true,
	["Ergonomics"] = true,
	["Weight"] = true
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
	self.IronSightTime = (1.5 - (self:GetStat("Ergonomics") * 0.01)) * 0.4
	self.MoveSpeed = 1 - ((self:GetStat("Weight") * 0.01) * 0.25)

	if CLIENT then
		--print("Ergonomics: " .. self:GetStat("Ergonomics"))
		--print("Weight: " .. self:GetStat("Weight"))
	end

	return BaseClass.Think2(self, ...)
end

--https://sun9-85.userapi.com/s/v1/ig2/n_WKNsnSh8wVwBFfDfMJrV6wOM1jj2VRLFWnQ_2YkHz2F2bZYe7rqE9aiY8lr56wV7sf0EmzV2I8SE8Nl8bKAbfc.jpg?size=800x450&quality=96&type=album