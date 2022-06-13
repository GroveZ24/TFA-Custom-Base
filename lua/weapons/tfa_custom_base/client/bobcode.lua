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
local walkRate = 150 / 60 * TAU / 1.085 / 2 * rateScaleFac
local walkVec = Vector()
local ownerVelocity, ownerVelocityMod = Vector(), Vector()
local zVelocity, zVelocitySmooth = 0, 0
local xVelocity, xVelocitySmooth, rightVec = 0, 0, Vector()
local flatVec = Vector(1, 1, 0)
local WalkPos = Vector()
local WalkPosLagged = Vector()
local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local gunbob_intensity = 0

SWEP.VMOffsetWalk = Vector(-0.25, -1, -0.5)
SWEP.VMAngleWalk = Angle(1, 2, -3)

SWEP.footstepTotal = 0
SWEP.footstepTotalTarget = 0

local upVec, riVec, fwVec = Vector(0, 0, 1), Vector(1, 0, 0), Vector(0, 1, 0)

local function l_Lerp(t, a, b)
	if t <= 0 then return a end
	if t >= 1 then return b end

	return a + (b - a) * t
end

--https://sun9-81.userapi.com/s/v1/ig2/7_7w-23Ry1-cHhz4P8mAO4fwlJNqtUozzoC5HW2skQ_6EtCzaVSzrH-2eDFk_GyLhbrvOF2zRWaw-KxphPJ_P_6Q.jpg?size=604x544&quality=95&type=album

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
	walkVec = LerpVector(walkIntensitySmooth, vector_origin, self2.VMOffsetWalk)
	walkAng = LerpAngle(walkIntensitySmooth, angle_origin, self2.VMAngleWalk)
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
	walkIntensity = walkIntensitySmooth * gunbob_intensity * 1.5

	local breatheMult2 = math.Clamp(self2.IronSightsProgressUnpredicted2 or self:GetIronSightsProgress(), 0, 1)
	local breatheMult1 = (1 - breatheMult2) - (self:GetInspectingProgress() * 0.75)

	----[[BREATHING]]----
	pos:Add(riLocal * (math.sin(self2.ti * walkRate * 0.5) - math.cos(self2.ti * walkRate)) * flip_v * breathIntensity * breatheMult1 * 0.1)
	pos:Add(upLocal * math.sin(self2.ti * walkRate * 1) * breathIntensity * breatheMult1 * 0.2)
	ang:RotateAroundAxis(ri, math.sin(self2.ti * walkRate * 1) * breathIntensity * breatheMult1 * 2)
	ang:RotateAroundAxis(up, (math.sin(self2.ti * walkRate * 0.5) - math.cos(self2.ti * walkRate)) * breathIntensity * breatheMult1 * 0.3)
	ang:RotateAroundAxis(fw, math.sin(self2.ti * walkRate * 0.5) * breathIntensity * breatheMult1 * 2)

	----[[ADS WALKING]]----
	pos:Add(riLocal * math.cos(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * 0.15)
	pos:Add(fwLocal * math.cos(self2.ti * walkRate) * breathIntensity * breatheMult2 * -0.2)
	pos:Add(upLocal * math.sin(self2.ti * walkRate) * breathIntensity * breatheMult2 * -0.15)
	ang:RotateAroundAxis(ri, math.sin(self2.ti * walkRate) * breathIntensity * breatheMult2 * -0.75)
	ang:RotateAroundAxis(up, math.sin(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * -1.5)
	ang:RotateAroundAxis(fw, math.sin(self2.ti * walkRate / 2) * breathIntensity * breatheMult2 * 2)

	----[[WALKING]]----
	self2.walkTI = (self2.walkTI or 0) + delta * 150 / 60 * self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed()
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

	----[[JUMPING]]----
	local trigX = -math.Clamp(zVelocitySmooth / 200, -1, 1) * math.pi / 2
	local jumpIntensity = (3 + math.Clamp(math.abs(zVelocitySmooth) - 100, 0, 200) / 200 * 4) * (1 - (self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()) * 0.5)

	pos:Add(up * math.sin(trigX) * scale_r * 0.1 * jumpIntensity * -0.5)
	ang:RotateAroundAxis(ri, math.sin(trigX) * scale_r * 0.1 * jumpIntensity * flip_v * -1.75)
	--https://sun9-59.userapi.com/s/v1/ig2/Y6jjUCuI43UDwEUAdIJ2IOpbFrcXzm5xAm4BZLYFxCPUa8-3aDmOmApOHDTmsSsqDBmeFw4JYp4Wwdy9rAcPox-E.jpg?size=1020x1293&quality=96&type=album

	----[[ROLLING WITH HORIZONTAL MOTION]]----
	local xVelocityClamped = xVelocitySmooth

	if math.abs(xVelocityClamped) > 200 then
		local sign = (xVelocityClamped < 0) and -1 or 1
		xVelocityClamped = (math.sqrt((math.abs(xVelocityClamped) - 200) / 50) * 50 + 200) * sign
	end

	pos:Add(riLocal * xVelocityClamped * 0.001 * flip_v * 0.7)
	pos:Add(fwLocal * math.abs(xVelocityClamped) * -0.0025 * 0.7)
	pos:Add(upLocal * math.abs(xVelocityClamped) * -0.001 * 0.7)
	ang:RotateAroundAxis(ri, math.abs(xVelocityClamped) * 0.0025 * 0.7)
	ang:RotateAroundAxis(up, xVelocityClamped * 0.005 * 0.7)
	ang:RotateAroundAxis(fw, xVelocityClamped * -0.02 * flip_v * 1.25)

	return pos, ang
end

function SWEP:SprintBob(pos, ang, intensity, origPos, origAng)
	local self2 = self:GetTable()
	if not IsValid(self:GetOwner()) or not gunbob_intensity or self2.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI then return pos, ang end

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