TFA.GUESS_NPC_WALKSPEED = 160

local function l_Lerp(t, a, b) return a + (b - a) * t end
local function l_mathMin(a, b) return (a < b) and a or b end
local function l_mathMax(a, b) return (a > b) and a or b end
local function l_ABS(a) return (a < 0) and -a or a end
local function l_mathClamp(t, a, b)
	if a > b then return b end

	if t > b then
		return b
	end

	if t < a then
		return a
	end

	return t
end

local function l_mathApproach(a, b, delta)
	if a < b then
		return l_mathMin(a + l_ABS(delta), b)
	else
		return l_mathMax(a - l_ABS(delta), b)
	end
end

local sprint_cv = GetConVar("sv_tfa_sprint_enabled")
local sv_tfa_weapon_weight = GetConVar("sv_tfa_weapon_weight")

function SWEP:TFAFinishMove(ply, velocity, movedata)
	local ft = FrameTime()
	local self2 = self:GetTable()
	local isply = ply:IsPlayer()

	if CLIENT then
		self2.LastUnpredictedVelocity = velocity
	end

	local speedmult = Lerp(self:GetIronSightsProgress(), sv_tfa_weapon_weight:GetBool() and self:GetStatL("RegularMoveSpeedMultiplier") or 1, self:GetStatL("AimingDownSightsSpeedMultiplier"))
	local jr_targ = math.min(math.abs(velocity.z) / 500, 1)

	self:SetJumpRatio(l_mathApproach(self:GetJumpRatio(), jr_targ, (jr_targ - self:GetJumpRatio()) * ft * 20))
	self2.JumpRatio = self:GetJumpRatio()
	self:SetCrouchingRatio(l_mathApproach(self:GetCrouchingRatio(), (self:IsOwnerCrouching()) and 1 or 0, ft / self2.ToCrouchTime))
	self2.CrouchingRatio = self:GetCrouchingRatio()

	local status = self2.GetStatus(self)
	local oldsprinting, oldwalking = self:GetSprinting(), self:GetWalking()
	local vellen = velocity:Length2D()

	if sprint_cv:GetBool() and not self:GetStatL("AllowSprintAttack", false) and movedata then
		self:SetSprinting(vellen > ply:GetRunSpeed() * 0.1 * speedmult and movedata:KeyDown(IN_SPEED) and ply:OnGround()) -- Тут
	else
		self:SetSprinting(false)
	end

	self:SetWalking(vellen > ((isply and ply:GetWalkSpeed() or TFA.GUESS_NPC_WALKSPEED) * (sv_tfa_weapon_weight:GetBool() and self:GetStatL("RegularMoveSpeedMultiplier", 1) or 1) * .75) and ply:GetNW2Bool("TFA_IsWalking") and ply:OnGround() and not self:GetSprinting() and not self:GetCustomizing())

	self2.walking_updated = oldwalking ~= self:GetWalking()
	self2.sprinting_updated = oldsprinting ~= self:GetSprinting()

	if self:GetCustomizing() and (self2.GetIronSights(self) or self:GetSprinting() or not TFA.Enum.ReadyStatus[status]) then
		self:ToggleCustomize()
	end

	local spr = self:GetSprinting()
	local walk = self:GetWalking()

	local sprt = spr and 1 or 0
	local walkt = walk and 1 or 0
	local adstransitionspeed = (spr or walk) and 7.5 or 12.5

	self:SetSprintProgress(l_mathApproach(self:GetSprintProgress(), sprt, (sprt - self:GetSprintProgress()) * ft * adstransitionspeed))
	self:SetWalkProgress(l_mathApproach(self:GetWalkProgress(), walkt, (walkt - self:GetWalkProgress()) * ft * adstransitionspeed))

	self:SetLastVelocity(vellen)
end

local sp = game.SinglePlayer()
local sv_tfa_recoil_legacy = GetConVar("sv_tfa_recoil_legacy")

function SWEP:CalculateRatios()
	local owent = self:GetOwner()
	if not IsValid(owent) then return end

	local self2 = self:GetTable()

	if self2.ratios_calc == nil then
		self2.ratios_calc = true
	end

	local ft = FrameTime()
	local time = CurTime()

	if ft <= 0 then return end

	local is = self2.GetIronSights(self)
	local spr = self2.GetSprinting(self)
	local walk = self2.GetWalking(self)

	local ist = is and 1 or 0
	local sprt = spr and 1 or 0
	local adstransitionspeed

	if is then
		adstransitionspeed = 12.5 / (self:GetStatL("IronSightTime") / 0.3)
	elseif spr or walk then
		adstransitionspeed = 7.5
	else
		adstransitionspeed = 12.5
	end

	if not owent:IsPlayer() then
		self:TFAFinishMove(owent, owent:GetVelocity())
	end

	local lastrecoiltime = self2.GetLastRecoil(self, -1)

	if lastrecoiltime < 0 or time >= (lastrecoiltime + self2.GetStatL(self, "Primary.SpreadRecoveryDelay")) then
		self:SetSpreadRatio(l_mathClamp(self:GetSpreadRatio() - self2.GetStatL(self, "Primary.SpreadRecovery") * ft, 1, self2.GetStatL(self, "Primary.SpreadMultiplierMax")))
	end

	self:SetIronSightsProgress(l_mathApproach(self:GetIronSightsProgress(), ist, (ist - self:GetIronSightsProgress()) * ft * adstransitionspeed))
	self:SetProceduralHolsterProgress(l_mathApproach(self:GetProceduralHolsterProgress(), sprt, (sprt - self:GetSprintProgress()) * ft * self2.ProceduralHolsterTime * 15))
	self:SetInspectingProgress(l_mathApproach(self:GetInspectingProgress(), self:GetCustomizing() and 1 or 0, ((self:GetCustomizing() and 1 or 0) - self:GetInspectingProgress()) * ft * 10))

	if self:GetRecoilThink() then
		if self:GetRecoilLoop() then

			if self:GetRecoilLoopWait() < time then
				self:SetRecoilOutProgress(l_mathMin(1, self:GetRecoilOutProgress() + ft / self2.Primary_TFA.RecoilLUT["out"].cooldown_speed))

				if self:GetRecoilOutProgress() == 1 then
					self:SetRecoilThink(false)
					self:SetRecoilLoop(false)
					self:SetRecoilLoopProgress(0)
					self:SetRecoilInProgress(0)
					self:SetRecoilOutProgress(0)
				end
			end
		else
			if self:GetRecoilInWait() < time then
				self:SetRecoilInProgress(l_mathMax(0, self:GetRecoilInProgress() - ft / self2.Primary_TFA.RecoilLUT["in"].cooldown_speed))

				if self:GetRecoilInProgress() == 0 then
					self:SetRecoilThink(false)
				end
			end
		end
	end

	if not sv_tfa_recoil_legacy:GetBool() then
		ft = l_mathClamp(ft, 0, 1)
		self:SetViewPunchBuild(l_mathMax(0, self:GetViewPunchBuild() - self:GetViewPunchBuild() * ft))
		local build = l_mathMax(0, 4.5 - self:GetViewPunchBuild())
		ft = ft * build * build
		self:SetViewPunchP(self:GetViewPunchP() - self:GetViewPunchP() * ft)
		self:SetViewPunchY(self:GetViewPunchY() - self:GetViewPunchY() * ft)
	end

	self2.SpreadRatio = self:GetSpreadRatio()
	self2.IronSightsProgress = self:GetIronSightsProgress()
	self2.SprintProgress = self:GetSprintProgress()
	self2.WalkProgress = self:GetWalkProgress()
	self2.ProceduralHolsterProgress = self:GetProceduralHolsterProgress()
	self2.InspectingProgress = self:GetInspectingProgress()

	if sp and CLIENT then
		self2.Inspecting = self:GetCustomizing()
	end

	self2.CLIronSightsProgress = self:GetIronSightsProgress()
end

SWEP.Primary.IronRecoilMultiplier = 0.5 --Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchRecoilMultiplier = 0.65 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.JumpRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.WallRecoilMultiplier = 1.1 --Multiply recoil by this factor when we're changing state e.g. not completely ironsighted.  This is proportional, not inversely.
SWEP.ChangeStateRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier = 0.5 --Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
SWEP.ChangeStateAccuracyMultiplier = 1.5 --Less is more.  A change of state is when we're in the progress of doing something, like crouching or ironsighting.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.JumpAccuracyMultiplier = 2 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.WalkAccuracyMultiplier = 1.35 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.ToCrouchTime = 0.25

local mult_cvar = GetConVar("sv_tfa_spread_multiplier")
local dynacc_cvar = GetConVar("sv_tfa_dynamicaccuracy")
local ccon, crec

SWEP.JumpRatio = 0

function SWEP:CalculateConeRecoil()
	local dynacc = false
	local self2 = self:GetTable()
	local isr = self:GetIronSightsProgress()

	if dynacc_cvar:GetBool() and (self2.GetStatL(self, "Primary.NumShots") <= 1) then
		dynacc = true
	end

	local isr_1 = l_mathClamp(isr * 2, 0, 1)
	local isr_2 = l_mathClamp((isr - 0.5) * 2, 0, 1)
	local acv = self2.GetStatL(self, "Primary.Spread") or self2.GetStatL(self, "Primary.Accuracy")
	local recv = self2.GetStatL(self, "Primary.Recoil") * 5

	if dynacc then
		ccon = l_Lerp(isr_2, l_Lerp(isr_1, acv, acv * self2.GetStatL(self, "ChangeStateAccuracyMultiplier")), self2.GetStatL(self, "Primary.IronAccuracy"))
		crec = l_Lerp(isr_2, l_Lerp(isr_1, recv, recv * self2.GetStatL(self, "ChangeStateRecoilMultiplier")), recv * self2.GetStatL(self, "Primary.IronRecoilMultiplier"))
	else
		ccon = l_Lerp(isr, acv, self2.GetStatL(self, "Primary.IronAccuracy"))
		crec = l_Lerp(isr, recv, recv * self2.GetStatL(self, "Primary.IronRecoilMultiplier"))
	end

	local crc_1 = l_mathClamp(self:GetCrouchingRatio() * 2, 0, 1)
	local crc_2 = l_mathClamp((self:GetCrouchingRatio() - 0.5) * 2, 0, 1)

	if dynacc then
		ccon = l_Lerp(crc_2, l_Lerp(crc_1, ccon, ccon * self2.GetStatL(self, "ChangeStateAccuracyMultiplier")), ccon * self2.GetStatL(self, "CrouchAccuracyMultiplier"))
		crec = l_Lerp(crc_2, l_Lerp(crc_1, crec, self2.GetStatL(self, "Primary.Recoil") * self2.GetStatL(self, "ChangeStateRecoilMultiplier")), crec * self2.GetStatL(self, "CrouchRecoilMultiplier"))
	end

	local owner = self:GetOwner()
	local isply = owner:IsPlayer()
	local ovel

	if IsValid(owner) then
		if owner:IsPlayer() then
			ovel = self:GetLastVelocity()
		else
			ovel = owner:GetVelocity():Length2D()
		end
	else
		ovel = 0
	end

	local vfc_1 = l_mathClamp(ovel / (isply and owner:GetWalkSpeed() or TFA.GUESS_NPC_WALKSPEED), 0, 2)

	if dynacc then
		ccon = l_Lerp(vfc_1, ccon, ccon * self2.GetStatL(self, "WalkAccuracyMultiplier"))
		crec = l_Lerp(vfc_1, crec, crec * self2.GetStatL(self, "WallRecoilMultiplier"))
	end

	local jr = self:GetJumpRatio()

	if dynacc then
		ccon = l_Lerp(jr, ccon, ccon * self2.GetStatL(self, "JumpAccuracyMultiplier"))
		crec = l_Lerp(jr, crec, crec * self2.GetStatL(self, "JumpRecoilMultiplier"))
	end

	ccon = ccon * self:GetSpreadRatio()

	if mult_cvar then
		ccon = ccon * mult_cvar:GetFloat()
	end

	if not isply and IsValid(owner) then
		local prof = owner:GetCurrentWeaponProficiency()

		if prof == WEAPON_PROFICIENCY_POOR then
			ccon = ccon * 8
		elseif prof == WEAPON_PROFICIENCY_AVERAGE then
			ccon = ccon * 5
		elseif prof == WEAPON_PROFICIENCY_GOOD then
			ccon = ccon * 3
		elseif prof == WEAPON_PROFICIENCY_VERY_GOOD then
			ccon = ccon * 2
		elseif prof == WEAPON_PROFICIENCY_PERFECT then
			ccon = ccon * 1.5
		end
	end

	return ccon, crec
end