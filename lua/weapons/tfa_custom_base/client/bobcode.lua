local vector_origin = Vector()
local angle_origin = Angle()

SWEP.ti = 0
SWEP.LastCalcBob = 0
SWEP.tiView = 0
SWEP.LastCalcViewBob = 0

local TAU = math.pi * 2
local rateScaleFac = 2
local rate_up = 6 * rateScaleFac
local scale_up = 0.5
local rate_right = 3 * rateScaleFac
local scale_right = -0.5
local rate_forward_view = 3 * rateScaleFac
local scale_forward_view = 0.35
local rate_right_view = 3 * rateScaleFac
local scale_right_view = -1
local rate_p = 6 * rateScaleFac
local scale_p = 3
local rate_y = 3 * rateScaleFac
local scale_y = 6
local rate_r = 3 * rateScaleFac
local scale_r = -6
local pist_rate = 3 * rateScaleFac
local pist_scale = 9
local rate_clamp = 2 * rateScaleFac
local walkIntensitySmooth, breathIntensitySmooth = 0, 0
local walkRate = 160 / 60 * TAU / 1.085 / 2 * rateScaleFac
local walkVec = Vector()
local ownerVelocity, ownerVelocityMod = Vector(), Vector()
local zVelocity, zVelocitySmooth = 0, 0
local xVelocity, xVelocitySmooth, rightVec = 0, 0, Vector()
local flatVec = Vector(1, 1, 0)
local WalkPos = Vector()
local WalkPosLagged = Vector()
local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local gunbob_intensity = 0

SWEP.WalkPos = Vector(-0.25, -0.75, -0.25)
SWEP.WalkAng = Angle(1, 2, -3)

SWEP.footstepTotal = 0
SWEP.footstepTotalTarget = 0

local upVec, riVec, fwVec = Vector(0, 0, 1), Vector(1, 0, 0), Vector(0, 1, 0)

local function l_Lerp(t, a, b)
	if t <= 0 then return a end
	if t >= 1 then return b end

	return a + (b - a) * t
end

--I HATE PROCEDURALS I HATE PROCEDURALS: https://sun9-81.userapi.com/s/v1/ig2/7_7w-23Ry1-cHhz4P8mAO4fwlJNqtUozzoC5HW2skQ_6EtCzaVSzrH-2eDFk_GyLhbrvOF2zRWaw-KxphPJ_P_6Q.jpg?size=604x544&quality=95&type=album

local HasLanded = false
local LandingFractionPosRi = 0
local LandingFractionPosFw = 0
local LandingFractionPosUp = 0
local LandingFractionAngRi = 0
local LandingFractionAngUp = 0
local LandingFractionAngFw = 0
local LandingFractionPosRiLerp = 0
local LandingFractionPosFwLerp = 0
local LandingFractionPosUpLerp = 0
local LandingFractionAngRiLerp = 0
local LandingFractionAngUpLerp = 0
local LandingFractionAngFwLerp = 0

local HasJumped = false
local JumpingFractionPosRi = 0
local JumpingFractionPosFw = 0
local JumpingFractionPosUp = 0
local JumpingFractionAngRi = 0
local JumpingFractionAngUp = 0
local JumpingFractionAngFw = 0
local JumpingFractionPosRiLerp = 0
local JumpingFractionPosFwLerp = 0
local JumpingFractionPosUpLerp = 0
local JumpingFractionAngRiLerp = 0
local JumpingFractionAngUpLerp = 0
local JumpingFractionAngFwLerp = 0

local DoSwitchAnim = false
local SwitchFractionPosRi = 0
local SwitchFractionPosFw = 0
local SwitchFractionPosUp = 0
local SwitchFractionAngRi = 0
local SwitchFractionAngUp = 0
local SwitchFractionAngFw = 0
local SwitchFractionPosRiLerp = 0
local SwitchFractionPosFwLerp = 0
local SwitchFractionPosUpLerp = 0
local SwitchFractionAngRiLerp = 0
local SwitchFractionAngUpLerp = 0
local SwitchFractionAngFwLerp = 0

function SWEP:WalkBob(pos, ang, breathIntensity, walkIntensity, rate, ftv)
	local self2 = self:GetTable()
	if not self2.OwnerIsValid(self) then return end

	rate = math.min(rate or 0.5, rate_clamp)
	gunbob_intensity = gunbob_intensity_cvar:GetFloat()

	local ea = self:GetOwner():EyeAngles()
	local up = ang:Up()
	local ri = ang:Right()
	local fw = ang:Forward()
	local upLocal = upVec
	local riLocal = riVec
	local fwLocal = fwVec
	local delta = ftv
	local flip_v = self2.ViewModelFlip and -1 or 1

	self2.bobRateCached = rate
	self2.ti = self2.ti + delta * rate

	if self2.SprintStyle == nil then
		if self:GetStatL("SprintViewModelAngle") and self:GetStatL("SprintViewModelAngle").x > 5 then
			self2.SprintStyle = 1
		else
			self2.SprintStyle = 0
		end
	end

	----[[PRECEDING CALCS]]----
	walkIntensitySmooth = l_Lerp(delta * 10 * rateScaleFac, walkIntensitySmooth, walkIntensity)
	breathIntensitySmooth = l_Lerp(delta * 10 * rateScaleFac, breathIntensitySmooth, breathIntensity)
	walkVec = LerpVector(walkIntensitySmooth, vector_origin, self2.WalkPos)
	walkAng = LerpAngle(walkIntensitySmooth, angle_origin, self2.WalkAng)
	ownerVelocity = self:GetOwner():GetVelocity()
	zVelocity = ownerVelocity.z
	zVelocitySmooth = l_Lerp(delta * 7 * rateScaleFac, zVelocitySmooth, zVelocity)
	ownerVelocityMod = ownerVelocity * flatVec
	ownerVelocityMod:Normalize()
	rightVec = ea:Right() * flatVec
	rightVec:Normalize()
	xVelocity = ownerVelocity:Length2D() * ownerVelocityMod:Dot(rightVec)
	xVelocitySmooth = l_Lerp(delta * 5 * rateScaleFac, xVelocitySmooth, xVelocity)

	----[[MULTIPLIERS]]----
	breathIntensity = breathIntensitySmooth * gunbob_intensity * 1.5
	walkIntensity = walkIntensitySmooth * gunbob_intensity * 1.5 * math.abs(1 - self:GetSprintProgress())

	local breatheMult2 = math.Clamp(self2.IronSightsProgressUnpredicted2 or self:GetIronSightsProgress(), 0, 1)
	local breatheMult1 = (1 - breatheMult2) - (self:GetInspectingProgress() * 0.75)

	----[[BREATHING]]----
	pos:Add(riLocal * (math.sin(self2.ti * walkRate * 1) - math.cos(self2.ti * walkRate)) * flip_v * breathIntensity * breatheMult1 * 0.1)
	pos:Add(upLocal * math.sin(self2.ti * walkRate * 1) * breathIntensity * breatheMult1 * 0.2)
	ang:RotateAroundAxis(ri, math.sin(self2.ti * walkRate * 1) * breathIntensity * breatheMult1 * 2)
	ang:RotateAroundAxis(up, (math.sin(self2.ti * walkRate * 0.25) - math.cos(self2.ti * walkRate)) * breathIntensity * breatheMult1 * -0.25)
	ang:RotateAroundAxis(fw, math.sin(self2.ti * walkRate * 0.5) * breathIntensity * breatheMult1 * -2)

	----[[ADS WALKING]]----
	pos:Add(riLocal * math.cos(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * 0.25)
	pos:Add(fwLocal * math.cos(self2.ti * walkRate) * breathIntensity * breatheMult2 * -0.15)
	pos:Add(upLocal * math.sin(self2.ti * walkRate) * breathIntensity * breatheMult2 * 0.2)
	ang:RotateAroundAxis(ri, math.sin(self2.ti * walkRate) * breathIntensity * breatheMult2 * 1.2)
	ang:RotateAroundAxis(up, math.sin(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * -1.5)
	ang:RotateAroundAxis(fw, math.sin(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * 2.5)

	----[[WALKING]]----
	self2.walkTI = (self2.walkTI or 0) + delta * 160 / 60 * self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed()
	WalkPos.x = l_Lerp(delta * 5 * rateScaleFac, WalkPos.x, -math.sin(self2.ti * walkRate * 0.5) * gunbob_intensity * walkIntensity * 0.45)
	WalkPos.y = l_Lerp(delta * 5 * rateScaleFac, WalkPos.y, math.sin(self2.ti * walkRate) / 1.5 * gunbob_intensity * walkIntensity * 0.2)
	WalkPosLagged.x = l_Lerp(delta * 5 * rateScaleFac, WalkPosLagged.x, -math.sin((self2.ti * walkRate * 0.5) + math.pi / 3) * gunbob_intensity * walkIntensity * 0.5)
	WalkPosLagged.y = l_Lerp(delta * 5 * rateScaleFac, WalkPosLagged.y, math.sin(self2.ti * walkRate + math.pi / 3) / 1.5 * gunbob_intensity * walkIntensity * 0.5)
	pos:Add(WalkPos.x * riLocal * 0.4)
	pos:Add(WalkPos.y * upLocal * 0.8)
	ang:RotateAroundAxis(ri, -WalkPosLagged.y * 2)
	ang:RotateAroundAxis(up, WalkPos.x * 3)
	ang:RotateAroundAxis(fw, WalkPos.y * 7.5)

	----[[CONSTANT OFFSET]]----
	pos:Add(riLocal * walkVec.x * flip_v)
	pos:Add(fwLocal * walkVec.y)
	pos:Add(upLocal * walkVec.z)
	ang:RotateAroundAxis(ri, walkAng.x)
	ang:RotateAroundAxis(up, walkAng.y)
	ang:RotateAroundAxis(fw, walkAng.z)

	----[[JUMPING + LANDING]]----

	local function LerpUnclamped(t, from, to)
		return t + (from - t) * to
	end

	local function InElasticEasedLerp(fraction, from, to)
		return LerpUnclamped(math.ease.InElastic(fraction), from, to)
	end

	local JumpADSMul = (1 - (self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()) * 0.5)
	local AnimSmoothing = 20
	local Mul2 = 1.75

	----[[LANDING]]----

	net.Receive("TFA_HasLanded", function(len, ply)
		HasLanded = true

		timer.Simple(0.001, function()
			HasLanded = false
		end)
	end)

	if HasLanded then
		LandingFractionPosUp = 1
		LandingFractionAngRi = 1
		LandingFractionAngFw = 1
	end

	LandingFractionPosUp = math.Approach(LandingFractionPosUp, 0, delta * 0.75)
	LandingFractionAngRi = math.Approach(LandingFractionAngRi, 0, delta * 0.5)
	LandingFractionAngFw = math.Approach(LandingFractionAngFw, 0, delta * 1.5)

	local LandingPosUp = InElasticEasedLerp(LandingFractionPosUp, 0, 2)
	local LandingAngRi = InElasticEasedLerp(LandingFractionAngRi, 0, 2)
	local LandingAngFw = InElasticEasedLerp(LandingFractionAngFw, 0, 2)

	LandingFractionPosUpLerp = Lerp(delta * AnimSmoothing, LandingFractionPosUpLerp, LandingPosUp * JumpADSMul * -0.4)
	LandingFractionAngRiLerp = Lerp(delta * AnimSmoothing, LandingFractionAngRiLerp, LandingAngRi * JumpADSMul * -3)
	LandingFractionAngFwLerp = Lerp(delta * AnimSmoothing, LandingFractionAngFwLerp, LandingAngFw * JumpADSMul * 1.5)

	pos:Add(up * LandingFractionPosUpLerp * Mul2)
	ang:RotateAroundAxis(ri, LandingFractionAngRiLerp * Mul2)
	ang:RotateAroundAxis(fw, LandingFractionAngFwLerp * Mul2)

	----[[JUMPING]]----

	net.Receive("TFA_HasJumped", function(len, ply)
		HasJumped = true

		timer.Simple(0.001, function()
			HasJumped = false
		end)
	end)

	if HasJumped then
		JumpingFractionPosUp = 1
		JumpingFractionAngRi = 1
		JumpingFractionAngFw = 1
	end

	JumpingFractionPosUp = math.Approach(JumpingFractionPosUp, 0, delta * 0.75)
	JumpingFractionAngRi = math.Approach(JumpingFractionAngRi, 0, delta * 0.5)
	JumpingFractionAngFw = math.Approach(JumpingFractionAngFw, 0, delta * 2)

	local JumpingPosUp = InElasticEasedLerp(JumpingFractionPosUp, 0, 2)
	local JumpingAngRi = InElasticEasedLerp(JumpingFractionAngRi, 0, 2)
	local JumpingAngFw = InElasticEasedLerp(JumpingFractionAngFw, 0, 2)

	JumpingFractionPosUpLerp = Lerp(delta * AnimSmoothing, JumpingFractionPosUpLerp, JumpingPosUp * JumpADSMul * -0.75)
	JumpingFractionAngRiLerp = Lerp(delta * AnimSmoothing, JumpingFractionAngRiLerp, JumpingAngRi * JumpADSMul * -5)
	JumpingFractionAngFwLerp = Lerp(delta * AnimSmoothing, JumpingFractionAngFwLerp, JumpingAngFw * JumpADSMul * -1.5)

	pos:Add(up * JumpingFractionPosUpLerp * Mul2)
	ang:RotateAroundAxis(ri, JumpingFractionAngRiLerp * Mul2)
	ang:RotateAroundAxis(fw, JumpingFractionAngFwLerp * Mul2)

	--Literally how I code this shit instead of sleeping (2 days well spent): https://sun9-42.userapi.com/s/v1/ig2/heCs_HZhZOlOrvZY0RQdM6M7jbwxt5HSKaXs4N28AsDRi2H5VcSwP-Y8b1QSpFWxHEmjbBv9MF0J8hxUza59X9yD.jpg?size=827x639&quality=96&type=album
	
	----[[MOD SWITCH]]----

	local function OutBackEasedLerp(fraction, from, to)
		return LerpUnclamped(math.ease.OutBack(fraction), from, to)
	end

	net.Receive("TFA_ModSwitch", function(len, ply)
		DoSwitchAnim = true

		timer.Simple(0.001, function()
			DoSwitchAnim = false
		end)
	end)

	if DoSwitchAnim then
		SwitchFractionPosRi = 1
		SwitchFractionPosFw = 1
		SwitchFractionPosUp = 1
		SwitchFractionAngRi = 1
		SwitchFractionAngUp = 1
		SwitchFractionAngFw = 1
	end

	SwitchFractionPosRi = math.Approach(SwitchFractionPosRi, 0, delta * 3)
	SwitchFractionPosFw = math.Approach(SwitchFractionPosFw, 0, delta * 0.8)
	SwitchFractionPosUp = math.Approach(SwitchFractionPosUp, 0, delta * 3)
	SwitchFractionAngRi = math.Approach(SwitchFractionAngRi, 0, delta * 0.6)
	SwitchFractionAngUp = math.Approach(SwitchFractionAngUp, 0, delta * 3)
	SwitchFractionAngFw = math.Approach(SwitchFractionAngFw, 0, delta * 1)

	local SwitchPosRi = OutBackEasedLerp(SwitchFractionPosRi, 0, 2)
	local SwitchPosFw = InElasticEasedLerp(SwitchFractionPosFw, 0, 2)
	local SwitchPosUp = OutBackEasedLerp(SwitchFractionPosUp, 0, 2)
	local SwitchAngRi = InElasticEasedLerp(SwitchFractionAngRi, 0, 2)
	local SwitchAngUp = OutBackEasedLerp(SwitchFractionAngUp, 0, 2)
	local SwitchAngFw = InElasticEasedLerp(SwitchFractionAngFw, 0, 2)

	SwitchFractionPosRiLerp = Lerp(delta * AnimSmoothing, SwitchFractionPosRiLerp, SwitchPosRi * 1)
	SwitchFractionPosFwLerp = Lerp(delta * AnimSmoothing, SwitchFractionPosFwLerp, SwitchPosFw * 1)
	SwitchFractionPosUpLerp = Lerp(delta * AnimSmoothing, SwitchFractionPosUpLerp, SwitchPosUp * 1)
	SwitchFractionAngRiLerp = Lerp(delta * AnimSmoothing, SwitchFractionAngRiLerp, SwitchAngRi * 1)
	SwitchFractionAngUpLerp = Lerp(delta * AnimSmoothing, SwitchFractionAngUpLerp, SwitchAngUp * 1)
	SwitchFractionAngFwLerp = Lerp(delta * AnimSmoothing, SwitchFractionAngFwLerp, SwitchAngFw * 1)

	pos:Add(ri * SwitchFractionPosRiLerp * 0.125)
	pos:Add(fw * SwitchFractionPosFwLerp * 0.15)
	pos:Add(up * SwitchFractionPosUpLerp * 0.05)
	ang:RotateAroundAxis(ri, SwitchFractionAngRiLerp * -0.5)
	ang:RotateAroundAxis(up, SwitchFractionAngUpLerp * -0.25)
	ang:RotateAroundAxis(fw, SwitchFractionAngFwLerp * 4)

	----[[ROLLING WITH HORIZONTAL MOTION]]----
	local xVelocityClamped = xVelocitySmooth

	if math.abs(xVelocityClamped) > 200 then
		local sign = (xVelocityClamped < 0) and -1 or 1
		xVelocityClamped = (math.sqrt((math.abs(xVelocityClamped) - 200) / 50) * 50 + 200) * sign
	end

	pos:Add(riLocal * xVelocityClamped * 0.001 * flip_v * 1)
	pos:Add(fwLocal * math.abs(xVelocityClamped) * -0.0025 * 0.75)
	pos:Add(upLocal * math.abs(xVelocityClamped) * 0.001 * flip_v * -0.25)
	ang:RotateAroundAxis(up, xVelocityClamped * 0.005 * 2)
	ang:RotateAroundAxis(fw, xVelocityClamped * -0.02 * flip_v * 1)

	return pos, ang
end

function SWEP:SprintBob(pos, ang, intensity, origPos, origAng)
	local self2 = self:GetTable()
	if not IsValid(self:GetOwner()) or not gunbob_intensity then return pos, ang end

	local flip_v = self2.ViewModelFlip and -1 or 1
	local eyeAngles = self:GetOwner():EyeAngles()
	local localUp = ang:Up()
	local localRight = ang:Right()
	local localForward = ang:Forward()
	local playerUp = eyeAngles:Up()
	local playerRight = eyeAngles:Right()
	local playerForward = eyeAngles:Forward()

	intensity = intensity * gunbob_intensity * 1.5
	gunbob_intensity = gunbob_intensity_cvar:GetFloat()

	if not self2.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI then
		if intensity > 0.005 then
			if self2.SprintStyle == 1 then
				local intensity3 = math.max(intensity - 0.3, 0) / (1 - 0.3)
				ang:RotateAroundAxis(ang:Up(), math.sin(self2.ti * pist_rate) * pist_scale * intensity3 * 0.33 * 0.75)
				ang:RotateAroundAxis(ang:Forward(), math.sin(self2.ti * pist_rate) * pist_scale * intensity3 * 0.33 * -0.25)
				pos:Add(ang:Forward() * math.sin(self2.ti * pist_rate * 2 + math.pi) * pist_scale * -0.1 * intensity3 * 0.4)
				pos:Add(ang:Right() * math.sin(self2.ti * pist_rate) * pist_scale * 0.15 * intensity3 * 0.33 * 0.2)
			else
				pos:Add(localUp * math.sin(self2.ti * rate_up + math.pi) * scale_up * intensity * 0.33)
				pos:Add(localRight * math.sin(self2.ti * rate_right) * scale_right * intensity * flip_v * 0.33)
				pos:Add(eyeAngles:Forward() * math.max(math.sin(self2.ti * rate_forward_view), 0) * scale_forward_view * intensity * 0.33)
				pos:Add(eyeAngles:Right() * math.sin(self2.ti * rate_right_view) * scale_right_view * intensity * flip_v * 0.33)
				ang:RotateAroundAxis(localRight, math.sin(self2.ti * rate_p + math.pi) * scale_p * intensity * 0.33)
				pos:Add(-localUp * math.sin(self2.ti * rate_p + math.pi) * scale_p * 0.1 * intensity * 0.33)
				ang:RotateAroundAxis(localUp, math.sin(self2.ti * rate_y) * scale_y * intensity * flip_v * 0.33)
				pos:Add(localRight * math.sin(self2.ti * rate_y) * scale_y * 0.1 * intensity * flip_v * 0.33)
				ang:RotateAroundAxis(localForward, math.sin(self2.ti * rate_r) * scale_r * intensity * flip_v * 0.33)
				pos:Add(localRight * math.sin(self2.ti * rate_r) * scale_r * 0.05 * intensity * flip_v * 0.33)
				pos:Add(localUp * math.sin(self2.ti * rate_r) * scale_r * 0.1 * intensity * 0.33)
			end
		end
	end

	return pos, ang
end

local cv_customgunbob = GetConVar("cl_tfa_gunbob_custom")
local fac, bscale

function SWEP:UpdateEngineBob()
	local self2 = self:GetTable()

	if cv_customgunbob:GetBool() then
		self2.BobScale = 0
		self2.SwayScale = 0

		return
	end

	local isp = self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()
	local wpr = self2.WalkProgressUnpredicted or self:GetWalkProgress()
	local spr = self:GetSprintProgress()

	fac = gunbob_intensity_cvar:GetFloat() * ((1 - isp) * 0.85 + 0.15)
	bscale = fac

	if spr > 0.005 then
		bscale = bscale * l_Lerp(spr, 1, self2.SprintBobMult)
	elseif wpr > 0.005 then
		bscale = bscale * l_Lerp(wpr, 1, l_Lerp(isp, self2.WalkBobMult, self2.WalkBobMult_Iron or self2.WalkBobMult))
	end

	self2.BobScale = bscale
	self2.SwayScale = fac
end