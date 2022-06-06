local gravity_cv = GetConVar("sv_gravity")
EFFECT.VelocityRandom = 0.25
EFFECT.VelocityMin = 95
EFFECT.VelocityMax = 125
EFFECT.ParticleCountMin = 4
EFFECT.ParticleCountMax = 7
EFFECT.ParticleLife = 1.3

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.Dir = data:GetNormal()
	self.LifeTime = 0.1
	self.DieTime = CurTime() + self.LifeTime
	self.PartMult = 0.2
	self.Grav = Vector(0, 0, -gravity_cv:GetFloat())
	self.SparkLife = 1
	local emitter = ParticleEmitter(self.StartPos)
	local partcount = math.random(self.ParticleCountMin, self.ParticleCountMax)

	--Sparks
	for _ = 1, partcount do
		local part = emitter:Add("effects/yellowflare", self.StartPos)
		part:SetVelocity(Lerp(self.VelocityRandom, self.Dir, VectorRand()) * math.Rand(self.VelocityMin, self.VelocityMax))
		part:SetDieTime(math.Rand(0.25, 1) * self.SparkLife)
		part:SetStartAlpha(0)
		part:SetStartSize(math.Rand(2, 4))
		part:SetEndSize(0)
		part:SetRoll(0)
		part:SetGravity(self.Grav)
		part:SetCollide(true)
		part:SetBounce(0.55)
		part:SetAirResistance(0.5)
		part:SetStartLength(0.2)
		part:SetEndLength(0)
		part:SetVelocityScale(true)
		part:SetCollide(true)
	end

	--Impact
	local part = emitter:Add("effects/yellowflare", self.StartPos)
	part:SetStartAlpha(0)
	part:SetStartSize(15 * self.PartMult)
	part:SetDieTime(self.LifeTime * 1)
	part:SetEndSize(0)
	part:SetEndAlpha(0)
	part:SetRoll(math.Rand(0, 360))
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
return false
end
