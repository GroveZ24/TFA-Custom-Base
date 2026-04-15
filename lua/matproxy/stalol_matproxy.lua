--Made by Stalol. Please do not distribute without his explicit permission, don't be an asshole

local basevec = Vector(1, 1, 1)
local resvar = "$envmaptint"
local HDRFix = 0

matproxy.Add({
	name = "TFACubemapMultiplier",

	init = function(self, mat, values)
		self.ResultVar = values.resultvar or resvar
		self.MultVar = values.multiplier
	end,

	bind = function(self, mat, ent)
		local rgbvec = basevec

		if IsValid(ent) then
			local mv = self.MultVar
			local lightvec = render.GetLightColor(ent:GetPos())

			if render.GetHDREnabled() then
				HDRFix = 25
			else
				HDRFix = 1
			end

			local average = (lightvec[1] + lightvec[2] + lightvec[3]) / 3 / HDRFix
			local coeff = mv and mat:GetVector(mv) or basevec
			rgbvec = Lerp(RealFrameTime() * 10, mat:GetVector(self.ResultVar), coeff * average)
		end

		mat:SetVector(self.ResultVar, rgbvec)
	end
})