--Made by Stalol. Please do not distribute without his explicit permission, don't be an asshole

local basevec = Vector(1, 1, 1)
local resvar = "$envmaptint"

matproxy.Add({
    name = "SAA_CubemapLightMult",

    init = function(self, mat, values)
        self.ResultVar = values.resultvar or resvar
        self.MultVar = values.multiplier
    end,

    bind = function(self, mat, ent)
        local rgbvec = basevec

        if IsValid(ent) then
            local mv = self.MultVar
            local lightvec = render.GetLightColor(ent:GetPos())
            local average = (lightvec[1] + lightvec[2] + lightvec[3]) / 3
            local coeff = mv and mat:GetVector(mv) or basevec
            rgbvec = Lerp(RealFrameTime() * 10, mat:GetVector(self.ResultVar), coeff * average)
        end

        mat:SetVector(self.ResultVar, rgbvec)
    end
})

matproxy.Add({
    name = "SAA_CubemapTintMult",

    init = function(self, mat, values)
        self.ResultVar = values.resultvar or resvar
        self.MultVar = values.multiplier
        self.Min = values.min
        self.Max = values.max
    end,

    bind = function(self, mat, ent)
        local rgbvec = basevec

        if IsValid(ent) then
            local mv = self.MultVar
            local lightvec = render.GetLightColor(ent:GetPos())
            local coeff = mv and mat:GetVector(mv) or basevec
            rgbvec = Lerp(RealFrameTime() * 10, mat:GetVector(self.ResultVar), coeff * lightvec)
        end

        mat:SetVector(self.ResultVar, rgbvec)
    end
})

local exvar = "$color2"

matproxy.Add({
    name = "SAA_ColorLightMult",

    init = function(self, mat, values)
        self.ResultVar = values.resultvar or exvar
        self.MultVar = values.multiplier
    end,

    bind = function(self, mat, ent)
        local rgbvec = basevec

        if IsValid(ent) then
            local mv = self.MultVar
            local lightvec = render.GetLightColor(ent:GetPos())
            local average = (lightvec[1] + lightvec[2] + lightvec[3]) / 3
            local coeff = mv and mat:GetVector(mv) or basevec
            rgbvec = Lerp(RealFrameTime() * 10, mat:GetVector(self.ResultVar), coeff * average)
        end

        mat:SetVector(self.ResultVar, rgbvec)
    end
})