function EFFECT:Init(data)
	local ply = data:GetEntity()
	local ent

	if IsValid(ply) and ply:IsPlayer() then
		ent = ply:GetActiveWeapon()
	end

	local sfac = (IsValid(ent) and ent.Primary and ent.Primary.Damage) and math.sqrt(ent.Primary.Damage / 30) or 1
	local sfac_sqrt = math.sqrt(sfac)
	local posoffset = data:GetOrigin()
	local forward = data:GetNormal()
	local emitter = ParticleEmitter(posoffset)

	for i = 0, math.Round(8 * sfac) do
		local p = emitter:Add("particle/particle_smokegrenade", posoffset)
		p:SetVelocity(90 * math.sqrt(i) * forward)
		p:SetAirResistance(400)
		p:SetStartAlpha(math.Rand(0, 0))
		p:SetEndAlpha(0)
		p:SetDieTime(math.Rand(0.75, 1) * (1 + math.sqrt(i) / 3))
		local iclamped = math.Clamp(i, 1, 8)
		local iclamped_sqrt = math.sqrt(iclamped / 8) * 8
		p:SetStartSize(math.Rand(1, 1) * sfac_sqrt * iclamped_sqrt)
		p:SetEndSize(math.Rand(1.5, 1.75) * sfac_sqrt * iclamped)
		p:SetRoll(math.Rand(-25, 25))
		p:SetRollDelta(math.Rand(-0.05, 0.05))
		p:SetColor(255, 255, 255)
		p:SetLighting(true)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
return false
end