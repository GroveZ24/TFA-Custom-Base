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
local walkRate = 125 / 60 * TAU / 1.085 / 2 * rateScaleFac
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
SWEP.WalkAng = Angle(0.5, 0, 0)

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
	walkIntensity = walkIntensitySmooth * gunbob_intensity * 1.15* math.abs(1 - self:GetSprintProgress())

	local breatheMult2 = math.Clamp(self2.IronSightsProgressUnpredicted2 or self:GetIronSightsProgress(), 0, 1)
	local breatheMult1 = (1 - breatheMult2) - (self:GetInspectingProgress() * 0.75)

	----[[BREATHING]]----
	-- Dual-frequency sine wave generation for breathing simulation
	local breathMain = math.sin(self2.ti * walkRate * 0.7)          -- Primary low-frequency wave (0.7x base rate)
	local breathSecondary = math.cos(self2.ti * walkRate * 0.35)    -- Secondary high-frequency wave (0.35x base rate)

	-- Additive positional offset accumulation with amplitude modulation
	pos:Add(riLocal * (breathMain * 0.8 - breathSecondary * 0.4) * flip_v * breathIntensity * breatheMult1 * 0.15)
	pos:Add(upLocal * (breathMain * 1.2 + breathSecondary * 0.3) * breathIntensity * breatheMult1 * 0.25)

	-- Angular displacement via axis rotation with intensity scaling
	ang:RotateAroundAxis(ri, breathMain * breathIntensity * breatheMult1 * 1.8)
	ang:RotateAroundAxis(up, (breathMain * 0.5 - breathSecondary * 0.7) * breathIntensity * breatheMult1 * -0.35)
	ang:RotateAroundAxis(fw, breathSecondary * breathIntensity * breatheMult1 * -2.2)

	-- High-frequency micro-oscillations for perceptual realism
	local microBreath = math.sin(self2.ti * walkRate * 2.5) * 0.2  -- 2.5x base frequency
	ang:RotateAroundAxis(up, microBreath * breathIntensity * breatheMult1 * 0.5)
	ang:RotateAroundAxis(fw, microBreath * breathIntensity * breatheMult1 * -0.8)

	-- Velocity-based amplitude attenuation using walk intensity
	local breathDamping = 1 - math.Clamp(walkIntensitySmooth * 0.7, 0, 0.6)  -- Inverse relationship with movement
	pos:Add(riLocal * breathMain * flip_v * breathIntensity * breatheMult1 * 0.1 * breathDamping)
	ang:RotateAroundAxis(ri, breathMain * breathIntensity * breatheMult1 * 1.0 * breathDamping)

	----[[ADS WALKING]]----
	-- Intensity scaling for ADS state with breath influence reduction
	local adsIntensity = breathIntensity * breatheMult2 * 0.95  -- 5% intensity reduction in ADS
	local walkSpeedRatio = math.Clamp(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 0, 0.8)  -- Speed ratio clamp

	-- Phase-shifted cosine waves for positional ADS sway
	pos:Add(riLocal * math.cos(self2.ti * walkRate * 0.475) * adsIntensity * 0.3)       -- 0.475x frequency multiplier
	pos:Add(fwLocal * math.cos(self2.ti * walkRate * 0.95) * adsIntensity * -0.19)      -- 0.95x frequency multiplier  
	pos:Add(upLocal * math.sin(self2.ti * walkRate * 0.95) * adsIntensity * 0.19)       -- 0.95x frequency multiplier

	-- Frequency-matched angular oscillations for ADS rotation
	ang:RotateAroundAxis(ri, math.sin(self2.ti * walkRate * 0.95) * adsIntensity * 1.14)   -- 0.95x frequency sync
	ang:RotateAroundAxis(up, math.sin(self2.ti * walkRate * 0.475) * adsIntensity * -1.71) -- 0.475x frequency sync
	ang:RotateAroundAxis(fw, math.sin(self2.ti * walkRate * 0.475) * adsIntensity * 2.66)  -- 0.475x frequency sync

	-- Exponential moving average filter for motion smoothing
	local smoothHoriz = l_Lerp(delta * 8.4 * rateScaleFac, self2.lastAdsHoriz or 0, math.cos(self2.ti * walkRate * 0.475) * 0.3)  -- 8.4x delta multiplier
	local smoothVert = l_Lerp(delta * 8.4 * rateScaleFac, self2.lastAdsVert or 0, math.sin(self2.ti * walkRate * 0.95) * 0.19)    -- 8.4x delta multiplier
	self2.lastAdsHoriz, self2.lastAdsVert = smoothHoriz, smoothVert  -- State persistence

	-- Application of filtered positional values
	pos:Add(riLocal * smoothHoriz * adsIntensity)
	pos:Add(upLocal * smoothVert * adsIntensity)

	----[[WALKING]]----
	-- Velocity ratio calculation with upper bound clamping
	local walkSpeedRatio = math.Clamp(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 0, 1.5)
	local isSprinting = self:GetSprintProgress() > 0.1
	local sprintInfluence = math.Clamp(self:GetSprintProgress() * 0.7, 0, 0.5)  -- Sprint impact coefficient

	-- ADS-based micro-movement attenuation factor
	local microMoveFactor = 1 - math.Clamp(self:GetIronSightsProgress(), 0.8, 1.0)  -- Linear attenuation from 0.8 to 1.0 ADS

	-- Time accumulation with velocity-proportional delta scaling
	self2.walkTI = (self2.ti or 0) + delta * 145 / 60 * walkSpeedRatio  -- 145/60 base rate scalar

	-- Multi-frequency wave generation for complex motion
	local baseBob = math.sin(self2.ti * walkRate * 0.55)           -- Primary oscillation (0.55x frequency)
	local microBob = math.sin(self2.ti * walkRate * 2.3) * 0.3     -- High-frequency component (2.3x frequency)
	local strideBob = math.sin(self2.ti * walkRate * 0.25) * 0.6   -- Low-frequency stride component (0.25x frequency)

	-- Low-pass filtered positional interpolation
	WalkPos.x = l_Lerp(delta * 8 * rateScaleFac, WalkPos.x, 
		(-baseBob * 0.4 + microBob * 0.15 - strideBob * 0.2) * gunbob_intensity * walkIntensity)  -- 8x delta multiplier

	WalkPos.y = l_Lerp(delta * 8 * rateScaleFac, WalkPos.y, 
		(math.sin(self2.ti * walkRate * 1.1) * 0.3 + microBob * 0.1) * gunbob_intensity * walkIntensity)  -- 8x delta multiplier

	-- Phase-offset lagged position accumulation
	WalkPosLagged.x = l_Lerp(delta * 5 * rateScaleFac, WalkPosLagged.x, 
		-math.sin((self2.ti * walkRate * 0.45) + math.pi / 3.5) * gunbob_intensity * walkIntensity * 0.4)  -- 5x delta, π/3.5 phase shift

	WalkPosLagged.y = l_Lerp(delta * 7 * rateScaleFac, WalkPosLagged.y, 
		math.sin(self2.ti * walkRate * 1.1 + math.pi / 3.5) * gunbob_intensity * walkIntensity * 0.35)  -- 7x delta, π/3.5 phase shift

	-- Sprint-modified tilt and sway parameters
	local sprintTilt = isSprinting and 0.8 or 1.0  -- 20% tilt reduction during sprint
	local sprintSway = isSprinting and 1.2 or 1.0  -- 20% sway increase during sprint

	-- Final positional application with sprint modulation
	pos:Add(WalkPos.x * riLocal * 0.85 * walkSpeedRatio * sprintTilt)  -- 0.85x amplitude coefficient
	pos:Add(WalkPos.y * upLocal * 1.1 * walkSpeedRatio)                -- 1.1x amplitude coefficient

	-- ADS-progressive rotation intensity scaling
	local adsFactor = 1 - math.Clamp(self:GetIronSightsProgress(), 0.5, 0.9)  -- 50-90% ADS attenuation range
	local rotationIntensity = math.Clamp(walkSpeedRatio * 1.3, 0.7, 1.4) * adsFactor  -- 1.3x speed coefficient

	-- Core rotational transformation system
	ang:RotateAroundAxis(ri, -WalkPosLagged.y * -2.0 * rotationIntensity * sprintSway)  -- 2.0x amplitude
	ang:RotateAroundAxis(up, WalkPos.x * 2.1 * rotationIntensity)                       -- 2.1x amplitude  
	ang:RotateAroundAxis(fw, WalkPos.y * 8.5 * rotationIntensity)                       -- 8.5x amplitude

	-- ADS-attenuated high-frequency rotational components
	ang:RotateAroundAxis(fw, microBob * 1.5 * rotationIntensity * microMoveFactor)  -- 1.5x micro-movement scale

	-- Low-frequency terrain response simulation
	local terrainBob = math.sin(self2.ti * walkRate * 0.15) * 0.4  -- 0.15x very low frequency
	ang:RotateAroundAxis(ri, terrainBob * walkIntensity * 0.8 * microMoveFactor)  -- 0.8x terrain intensity

	-- Velocity-dependent idle oscillation system
	if walkSpeedRatio < 0.3 then
		local idleSway = math.sin(self2.ti * walkRate * 0.8) * 0.3  -- 0.8x idle frequency
		ang:RotateAroundAxis(up, idleSway * (1 - walkSpeedRatio) * 0.5 * microMoveFactor)  -- Inverse speed relationship
	end

	--[[ smoother var
	local walkSpeedRatio = math.Clamp(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 0, 1.5)
	self2.walkTI = (self2.walkTI or 0) + delta * 160 / 60 * walkSpeedRatio -- Оригинальная скорость

	WalkPos.x = l_Lerp(delta * 12 * rateScaleFac, WalkPos.x, -math.sin(self2.ti * walkRate * 0.5) * gunbob_intensity * walkIntensity * 0.55)
	WalkPos.y = l_Lerp(delta * 12 * rateScaleFac, WalkPos.y, math.sin(self2.ti * walkRate) / 1.5 * gunbob_intensity * walkIntensity * 0.25)
	WalkPosLagged.x = l_Lerp(delta * 10 * rateScaleFac, WalkPosLagged.x, -math.sin((self2.ti * walkRate * 0.5) + math.pi / 3) * gunbob_intensity * walkIntensity * 0.5)
	WalkPosLagged.y = l_Lerp(delta * 10 * rateScaleFac, WalkPosLagged.y, math.sin(self2.ti * walkRate + math.pi / 3) / 1.5 * gunbob_intensity * walkIntensity * 0.5)

	local smoothPosX = l_Lerp(delta * 15, self2.lastPosX or 0, WalkPos.x)
	local smoothPosY = l_Lerp(delta * 15, self2.lastPosY or 0, WalkPos.y)
	local smoothLagX = l_Lerp(delta * 12, self2.lastLagX or 0, WalkPosLagged.x)
	local smoothLagY = l_Lerp(delta * 12, self2.lastLagY or 0, WalkPosLagged.y)

	self2.lastPosX, self2.lastPosY = smoothPosX, smoothPosY
	self2.lastLagX, self2.lastLagY = smoothLagX, smoothLagY

	pos:Add(smoothPosX * riLocal * 0.8)
	pos:Add(smoothPosY * upLocal * 1)

	ang:RotateAroundAxis(ri, -smoothLagY * -1.65)
	ang:RotateAroundAxis(up, smoothPosX * 1.7)
	ang:RotateAroundAxis(fw, smoothPosY * 8.5)

	local microSmooth = math.sin(self2.ti * walkRate * 3.0) * 0.1
	ang:RotateAroundAxis(up, microSmooth * walkIntensity * 0.3)
	ang:RotateAroundAxis(ri, microSmooth * walkIntensity * 0.2)
	]]

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
	local Mul2 = 1.25

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

	JumpingFractionPosUpLerp = Lerp(delta * AnimSmoothing, JumpingFractionPosUpLerp, JumpingPosUp * JumpADSMul * -1.5)
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