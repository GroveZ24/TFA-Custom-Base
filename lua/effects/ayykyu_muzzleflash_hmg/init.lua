local blankvec = Vector(0, 0, 0)

function EFFECT:Init(data)
	self.Position = blankvec
	self.WeaponEnt = data:GetEntity()
	self.WeaponEntOG = self.WeaponEnt
	self.Attachment = data:GetAttachment()
	self.Dir = data:GetNormal()
	local owent

	if IsValid(self.WeaponEnt) then
		owent = self.WeaponEnt:GetOwner()
	end

	if not IsValid(owent) then
		owent = self.WeaponEnt:GetParent()
	end

	if IsValid(owent) and owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()

			if IsValid(theirweapon) and theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped then
				self.Flipped = true
			end

			if not IsValid(self.WeaponEnt) then return end
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.MuzzleAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.MuzzleAttachment)

		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 1
		end

		if self.WeaponEntOG.Akimbo then
			self.Attachment = 2 - self.WeaponEntOG.AnimCycle
		end
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)

	if not angpos or not angpos.Pos then
		angpos = {
			Pos = vector_origin,
			Ang = angle_zero
		}
	end

	if self.Flipped then
		local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		--localang:RotateAroundAxis(localang:Up(),180)
		--tmpang:RotateAroundAxis(tmpang:Up(),180)
		self.Dir = localang:Forward()
	end

	-- Keep the start and end Pos - we're going to interpolate between them
	self.Position = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
	self.Norm = self.Dir
	self.vOffset = self.Position
	local dir = self.Norm

if GetConVar( "fas2_flashes_dynlight" ):GetFloat() >= 1 then
	
	local dlight
	
	if IsValid(self.WeaponEnt) then
		dlight = DynamicLight(self.WeaponEnt:EntIndex())
	else
		dlight = DynamicLight(0)
	end

	local fadeouttime = 0.025

	if (dlight) then
		dlight.Pos = self.Position + dir * 1 - dir:Angle():Right() * 5
		dlight.r = 255
		dlight.g = 192
		dlight.b = 64
		dlight.brightness = 1
		dlight.Decay = 500
		dlight.Size = 1024
		dlight.DieTime = CurTime() + fadeouttime
	end
	
end

	ParticleEffectAttach("muzzleflash_hmg", PATTACH_POINT_FOLLOW, self.WeaponEnt, data:GetAttachment())
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end