DEFINE_BASECLASS("tfa_gun_base")

--[[
Attachments should be:
1 - muzzle - Muzzleflash, unsuppressed
2 - muzzle_supp - Muzzleflash, suppressed (Also should be parrented to muzzleflash bone)
3 - shell - Shell ejection port
4 - camera - Camera, obviously
5 - flashlight_lightsource - Position of flashlight's light emission (Also should be parrented to flashlight bone)
--]]

--[[

//DO NOT TOUCH

if SERVER then 
	util.AddNetworkString("send_nudes")

	net.Receive("send_nudes", function(len, ply)
		local pos = net.ReadVector()
		local ang = net.ReadAngle()

		ang:Normalize()

		ply.BorePose = pos
		ply.BoreAng = ang

		--print(pos)
		--print(ang)
	end)
end

if CLIENT then 
	hook.Add("PostDrawViewModel", "ASDSADASDASD", function(vm, ply, wep)
		local data = vm:GetAttachment("1")

		net.Start("send_nudes")
		net.WriteVector(data.Pos)
		net.WriteAngle(data.Ang)
		net.SendToServer()
	end)
end

--]]

----[[PROPERTIES]]----

SWEP.TFADataVersion = 0
SWEP.Manufacturer = ""
SWEP.Author = "Unknown"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Calibre = ""
SWEP.GRAU = nil
SWEP.Country = ""
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Type = "Rifle" -- "Pistol" "Machine Pistol" "Revolver" "Sub-Machine Gun" "Rifle" "Carbine" "Light Machine Gun" "Shotgun" "Designated Marksman Rifle" "Sniper Rifle" "Grenade" "Launcher"
SWEP.Type_Displayed = "Assault Rifle"
SWEP.EditedTFABase = true

----[[CUSTOM STATS]]----

SWEP.Ergonomics = 30
SWEP.Weight = 3

----[[RECOIL]]----

SWEP.IronRecoilMultiplier = 0.95
SWEP.CrouchRecoilMultiplier = 0.9
SWEP.JumpRecoilMultiplier = 1.5
SWEP.WallRecoilMultiplier = 1
SWEP.ChangeStateRecoilMultiplier = 1.25

----[[ACCURACY]]----

SWEP.CrouchAccuracyMultiplier = 0.75
SWEP.ChangeStateAccuracyMultiplier = 2.5
SWEP.JumpAccuracyMultiplier = 5
SWEP.WalkAccuracyMultiplier = 1.75

----[[MISC]]----

SWEP.ViewModelPunchPitchMultiplier = 0
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0
SWEP.ViewModelPunch_MaxVertialOffset = 0
SWEP.ViewModelPunch_MaxVertialOffset_IronSights = 0
SWEP.ViewModelPunch_VertialMultiplier = 0
SWEP.ViewModelPunch_VertialMultiplier_IronSights = 0
SWEP.ViewModelPunchYawMultiplier = 0
SWEP.ViewModelPunchYawMultiplier_IronSights = 0

SWEP.ToCrouchTime = 0.35

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

SWEP.CanReloadWhileSprinting = true

hook.Add("StartCommand", "TFA_Disable_Sprint", function(ply, cmd)
	local wep = ply:GetActiveWeapon()

	if not wep.IsTFAWeapon then return end
	if not wep.EditedTFABase then return end
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

----[[MOD SWITCH ANIMS]]----

SWEP.UseModSwitchProceduralAnimation = false

function SWEP:ChooseModSwitchAnim()
	return self:PlayAnimation(self:GetStat("ModSwitchAnimation.mod_switch"))
end

if SERVER then
	util.AddNetworkString("TFA_ModSwitch")

	hook.Add("PlayerSwitchFlashlight", "TFA_Mod_Switch_Anim", function(plyv, toEnable)
		local wepv = plyv:GetActiveWeapon()

		if wepv.HasFlashlight == false then return false end

		if wepv.UseModSwitchProceduralAnimation then
			net.Start("TFA_ModSwitch")
			net.Send(plyv)

			plyv:ViewPunch(Angle(0.25, 0, -0.25))
		else
			if (IsValid(wepv) and wepv.GetStat) and wepv:GetStatus() == TFA.Enum.STATUS_IDLE and wepv.EFTWeapon and wepv.EnableFlashlight and not plyv:KeyDown(IN_WALK) then
				local _, tanim = wepv:ChooseModSwitchAnim()
				wepv:ScheduleStatus(TFA.Enum.STATUS_IDLE, wepv:GetActivityLength())
			else
				return false
			end
		end
	end)
end

--Example of using animation instead is down below:

--[[
SWEP.ModSwitchAnimation = {
	["mod_switch"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ,
		["value"] = "ACT_VM_MOD_SWITCH"
	}
}
--]]

----[[FLASHLIGHT]]----

SWEP.HasFlashlight = false
SWEP.FlashlightAttachment = 0
SWEP.FlashlightDistance = 0
SWEP.FlashlightBrightness = 0
SWEP.FlashlightFOV = 0
SWEP.FlashlightSoundToggleOn = Sound("")
SWEP.FlashlightSoundToggleOff = Sound("")
SWEP.FlashlightMaterial = "effects/flashlight001"

----[[LASER]]----

SWEP.LaserDistance = 10000

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

SWEP.IronSightsOffsetSmoothing = 7.5

local IronSights = 0
local IronSightsLerp = 0

function SWEP:SightsPoseParameter()
	local VM = LocalPlayer():GetViewModel() or NULL
	local IronSightProgress = LocalPlayer():GetActiveWeapon().IronSightsProgress
	local IronSightsBool = LocalPlayer():GetActiveWeapon():GetIronSights()

	if IronSightsBool then
		IronSights = 1
	else
		IronSights = 0
	end

	IronSightsLerp = Lerp(FrameTime() * LocalPlayer():GetActiveWeapon().IronSightsOffsetSmoothing, IronSightsLerp, IronSights)

	if VM:IsValid() then
		self.OwnerViewModel:SetPoseParameter("sights", IronSightProgress)
		self.OwnerViewModel:SetPoseParameter("sights_offset", IronSightsLerp)
		self.OwnerViewModel:InvalidateBoneCache()
	end
end

----[[EMPTY POSE PARAMETER]]----

function SWEP:EmptyPoseParameter()
	if self:Clip1() > 0 then
		self.OwnerViewModel:SetPoseParameter("empty", 0)
	else
		self.OwnerViewModel:SetPoseParameter("empty", 1)
	end
	
	self.OwnerViewModel:InvalidateBoneCache()
end

----[[STAT CACHE BLACKLIST]]----

SWEP.StatCache_Blacklist = {
	["IronSightTime"] = true,
	["MoveSpeed"] = true,
	["Ergonomics"] = true,
	["Weight"] = true,
	["VElements"] = true,
	["ViewModelBoneMods"] = true
}

----[[THINK]]----

function SWEP:Think(...)
	if CLIENT then
		self:SightsPoseParameter()
		self:EmptyPoseParameter()
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