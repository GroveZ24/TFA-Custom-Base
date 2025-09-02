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
SWEP.Caliber = ""
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

----[[FOREGRIPS RELATED]]----

SWEP.GripPoseParameterName = "grip_default"
SWEP.GripChangePoseSpeed = 10
SWEP.GripFactor = 0

function SWEP:TFAEnableForegrip()
	self.GripFactor = 1
end

function SWEP:TFADisableForegrip()
	self.GripFactor = 0
end

local GripProgress = 0

function SWEP:GripPoseParameter()
	local VM = LocalPlayer():GetViewModel() or NULL
	local GripFactor = self.GripFactor

	GripProgress = Lerp(FrameTime() * LocalPlayer():GetActiveWeapon().GripChangePoseSpeed, GripProgress, GripFactor)

	if VM:IsValid() then
		self.OwnerViewModel:SetPoseParameter(LocalPlayer():GetActiveWeapon().GripPoseParameterName, GripProgress)
		self.OwnerViewModel:InvalidateBoneCache()
	end
end

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
--[[
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
]]
hook.Add("PlayerSwitchFlashlight", "TFA_Mod_Switch_Anim", function(plyv, toEnable)
    local wepv = plyv:GetActiveWeapon()
    if not IsValid(wepv) then return end

    if not wepv.HasFlashlight then
        return
    end

    if wepv.UseModSwitchProceduralAnimation then
        net.Start("TFA_ModSwitch")
        net.Send(plyv)
        plyv:ViewPunch(Angle(0.25, 0, -0.25))
    else
        if (wepv.GetStat and wepv:GetStatus() == TFA.Enum.STATUS_IDLE and wepv.EFTWeapon and wepv.EnableFlashlight and not plyv:KeyDown(IN_WALK)) then
            local _, tanim = wepv:ChooseModSwitchAnim()
            wepv:ScheduleStatus(TFA.Enum.STATUS_IDLE, wepv:GetActivityLength())
        else
            return false
        end
    end

		return false
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
local freevm_last_state = 0
local fp, fa -- Position and angle storage

hook.Add("CalcViewModelView", "TFA_Debug_FreeVM", function(w, v, op, oa, p, a)
    local current_state = freevm_var:GetFloat()
    
    -- Reset position when enabling free VM
    if current_state == 1 and freevm_last_state ~= 1 then
        fp, fa = Vector(p), Angle(a)
    end
    
    freevm_last_state = current_state
    
    if current_state == 1 then
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
	["ViewModelBoneMods"] = true,
	["GripFactor"] = true,
	["Primary_TFA"] = {
		["SpreadMultiplierMax"] = true,
		["SpreadIncrement"] = true,
		["SpreadRecovery"] = true,
	},
}

----[[THINK]]----

function SWEP:Think(...)
	if CLIENT then
		self:SightsPoseParameter()
		self:EmptyPoseParameter()
		self:GripPoseParameter()
	end

	return BaseClass.Think(self, ...)
end

----[[THINK2: ELECTRIC BOOGALOO]]----

SWEP.UseCustomSpreadCalculationAlgorithm = false

function SWEP:Think2(...)
	self.IronSightTime = (1.5 - (self:GetStat("Ergonomics") * 0.01)) * 0.4
	self.MoveSpeed = 1 - ((self:GetStat("Weight") * 0.01) * 0.25)

	if self.UseCustomSpreadCalculationAlgorithm then
		self.Primary_TFA.SpreadMultiplierMax = self:GetStat("Primary_TFA.SpreadMultiplierMaxCustom") + (self.IronSightsProgress * (self:GetStat("Primary_TFA.Spread") / self:GetStat("Primary_TFA.IronAccuracy")) * 1)
		self.Primary_TFA.SpreadIncrement = self:GetStat("Primary_TFA.SpreadIncrementCustom") + (self.IronSightsProgress * (self:GetStat("Primary_TFA.Spread") / self:GetStat("Primary_TFA.IronAccuracy")) * 0.25)
		self.Primary_TFA.SpreadRecovery = self:GetStat("Primary_TFA.SpreadRecoveryCustom") + (self.IronSightsProgress * (self:GetStat("Primary_TFA.Spread") / self:GetStat("Primary_TFA.IronAccuracy")) * 2)
	end

	--Modern problems require modern solutions
	--At least it works the way I wanted it to
	--https://sun9-64.userapi.com/impg/VggW6BSJkUhFOqjjQZbQz_BI-l_Kdw2tY-7Pbw/TITOIqRYfiI.jpg?size=355x355&quality=96&sign=9da6e4528d986fb40880c847e115fd45&type=album

	if CLIENT then
	--[[
		print("Ergonomics: " .. self:GetStat("Ergonomics"))
		print("Weight: " .. self:GetStat("Weight"))
	--]]
	end

	--https://sun9-85.userapi.com/s/v1/ig2/n_WKNsnSh8wVwBFfDfMJrV6wOM1jj2VRLFWnQ_2YkHz2F2bZYe7rqE9aiY8lr56wV7sf0EmzV2I8SE8Nl8bKAbfc.jpg?size=800x450&quality=96&type=album

	return BaseClass.Think2(self, ...)
end

----[[LASTRECOIL TRACKER]]----

timer.Simple(0, function()
    if not SWEP then return end
    if not SWEP.Recoil then return end

    local OriginalRecoil = SWEP.Recoil

    function SWEP:Recoil(recoil, ...)
        self.LastRecoil = tonumber(recoil) or 0
        return OriginalRecoil(self, recoil, ...)
    end
end)

function SWEP:GetLastRecoil()
    local val = self.LastRecoil or self:GetStatL("Primary.Recoil") or 0
    return tonumber(val) or 0
end

----[[FreeAim]]----

--[[ CLIENT SIDE ]]--
if CLIENT then
    util.AddNetworkString = util.AddNetworkString or function() end

    -- Function to get muzzle attachment or fallback bone position
    local function GetMuzzle(vm)
        if not IsValid(vm) then return nil end
        local attID = vm:LookupAttachment("muzzle") -- try to find attachment
        local attData = attID and vm:GetAttachment(attID)
        if not attData then
            local boneID = vm:LookupBone("muzzle") -- fallback to bone
            if boneID then
                local pos, ang = vm:GetBonePosition(boneID)
                if pos and ang then
                    attData = { Pos = pos, Ang = ang }
                end
            end
        end
        return attData
    end

    local NextMuzzleSend = 0
    -- Hook Think to periodically send muzzle position to server
    hook.Add("Think", "TFA_Custom_Base_MuzzleUpdate", function()
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.IsTFAWeapon then return end
        local vm = ply:GetViewModel()
        if not IsValid(vm) then return end

        if CurTime() >= NextMuzzleSend then
            local att = GetMuzzle(vm)
            if att then
                -- Send muzzle position and forward direction to server
                net.Start("TFA_Custom_Base_UpdateMuzzle")
                    net.WriteVector(att.Pos)
                    net.WriteVector(att.Ang:Forward())
                net.SendToServer()
            end
            NextMuzzleSend = CurTime() + 0.01 -- update every 0.01 seconds
        end
    end)
end

---[[ SERVER SIDE ]]---
--[[
if SERVER then
    util.AddNetworkString("TFA_Custom_Base_UpdateMuzzle")
    local playerMuzzleData = {}

    --Receive muzzle info from client
    net.Receive("TFA_Custom_Base_UpdateMuzzle", function(_, ply)
        if not IsValid(ply) then return end
        local pos = net.ReadVector()
        local dir = net.ReadVector():GetNormalized()

        --Anti-cheat: ensure the muzzle isn't too far from eyes
        if pos:DistToSqr(ply:EyePos()) > 10000 then return end
        playerMuzzleData[ply] = { Pos = pos, Dir = dir }
    end)

    --Shoot from last known muzzle position
    function SWEP:ShootFromMuzzle()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        local data = playerMuzzleData[ply]
        local src, dir = ply:EyePos(), ply:EyeAngles():Forward() --fallback if no data
        if data then
            src, dir = data.Pos, data.Dir

            --Prevent shooting from inside walls
            local trace = util.TraceLine({
                start = ply:EyePos(),
                endpos = src,
                filter = ply,
                mask = MASK_SHOT
            })
            if trace.Hit then
                src = ply:EyePos() + dir * 5
            end
        end

        ply:LagCompensation(true)

        local bullet = {}
        bullet.Num    = self:GetStatL("Primary.NumShots") or 1
        bullet.Src    = src
        bullet.Dir    = dir
        bullet.Spread = Vector(self:GetStatL("Primary.Spread") or 0, self:GetStatL("Primary.Spread") or 0, 0)
        bullet.Tracer = 1
        bullet.Force  = self:GetStatL("Primary.Force") or 10
        bullet.Damage = self:GetStatL("Primary.Damage") or 20
        bullet.Ammo   = self:GetStatL("Primary.Ammo") or "SMG1"

        ply:FireBullets(bullet)
        ply:LagCompensation(false)
    end

    --Override PrimaryAttack to use muzzle shooting
    function SWEP:PrimaryAttack()
        if not self:CanPrimaryAttack() then return end
        self:ShootFromMuzzle()
        self:TakePrimaryAmmo(1)
        self:SetNextPrimaryFire(CurTime() + (60 / (self:GetStatL("Primary.RPM") or 600)))
    end
end
]]

----[[FreeAim Debug]]----
--[[
if CLIENT then
    local debugMuzzle3D = {}
    --ConVar to toggle muzzle debug visualization
    local debugEnabled = CreateConVar("cl_tfa_debug_freeaim", "0", FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Enable TFA muzzle debug") 

    --Function to get muzzle attachment or bone
    local function GetMuzzle(vm)
        if not IsValid(vm) then return nil end
        local attID = vm:LookupAttachment("muzzle")
        local attData = attID and vm:GetAttachment(attID)
        if not attData then
            local boneID = vm:LookupBone("muzzle")
            if boneID then
                local pos, ang = vm:GetBonePosition(boneID)
                if pos and ang then
                    attData = { Pos = pos, Ang = ang }
                end
            end
        end
        return attData
    end

    --Update muzzle debug data each frame
    hook.Add("Think", "TFA_Debug3D_UpdateMuzzle", function()
        if not debugEnabled:GetBool() then return end

        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.IsTFAWeapon then return end
        local vm = ply:GetViewModel()
        if not IsValid(vm) then return end

        local att = GetMuzzle(vm)
        if att then
            debugMuzzle3D[ply] = { pos = att.Pos, ang = att.Ang }
        end
    end)

    --Draw the muzzle debug lines and boxes
    hook.Add("PostDrawOpaqueRenderables", "TFA_Debug3D_DrawMuzzle", function()
        if not debugEnabled:GetBool() then return end

        local ply = LocalPlayer()
        local data = debugMuzzle3D[ply]
        if not data or not data.pos or not data.ang then return end

        local startPos = data.pos
        --Trace to see where the bullet would hit
        local trace = util.TraceLine({
            start = startPos,
            endpos = startPos + data.ang:Forward() * 5000,
            filter = ply
        })
        local endPos = trace.HitPos

        render.SetColorMaterial()

        --Draw line from muzzle to hit point
        render.DrawLine(startPos, endPos, Color(0, 255, 0), true)

        --Small green box at muzzle
        local boxSize = 1.5
        render.DrawBox(startPos, Angle(0,0,0), Vector(-boxSize,-boxSize,-boxSize), Vector(boxSize,boxSize,boxSize), Color(0,255,0), true)

        --Slightly bigger red box at hit point
        local hitBoxSize = 2.5
        render.DrawBox(endPos, Angle(0,0,0), Vector(-hitBoxSize,-hitBoxSize,-hitBoxSize), Vector(hitBoxSize,hitBoxSize,hitBoxSize), Color(255,0,0), true)
    end)
end
]]

















