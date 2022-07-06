AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.PrintName = "Mag"
ENT.Category = ""
ENT.Spawnable = false
ENT.Model = ""
ENT.Bodygroups = ""
ENT.TextureGroup = 0
ENT.RemovalTimer = 1

ENT.ImpactSounds = {
	"physics/metal/weapon_impact_hard1.wav"
}

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)
		self:SetBodyGroups(self.Bodygroups)
		self:SetSkin(self.TextureGroup)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:PhysWake()

		local phys = self:GetPhysicsObject()

		if !phys:IsValid() then
			self:PhysicsInitBox(Vector(-1, -1, -1), Vector(1, 1, 1))
		end
	end

	self.SpawnTime = CurTime()
end

function ENT:PhysicsCollide(colData, collider)
	if SERVER then
		if colData.DeltaTime < 0.5 then return end

		local tbl = self.ImpactSounds
		tbl.BaseClass = nil

		local snd = ""

		if tbl then
			snd = table.Random(tbl)
		end

		self:EmitSound(snd)
	end
end

function ENT:Think()
	if SERVER then
		local MagRemovalTimer = self.RemovalTimer

		if !self.SpawnTime then
			self.SpawnTime = CurTime()
		end

		if (self.SpawnTime + MagRemovalTimer) <= CurTime() then

			self:SetRenderFX(kRenderFxFadeFast)

			if (self.SpawnTime + MagRemovalTimer + 1) <= CurTime() then

				if IsValid(self:GetPhysicsObject()) then
					self:GetPhysicsObject():EnableMotion(false)
				end

				if (self.SpawnTime + MagRemovalTimer + 1.5) <= CurTime() then
					self:Remove()

					return
				end
			end
		end
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end