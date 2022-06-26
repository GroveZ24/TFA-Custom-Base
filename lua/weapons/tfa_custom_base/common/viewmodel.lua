local vector_origin = Vector()
local angle_zero = Angle()

SWEP.WeaponLength = 0

SWEP.NearWallPos = Vector(0.091287083923817, -0.4564354121685, -0.18257416784763)
SWEP.NearWallPosADS = Vector(0.091287083923817 * 0.15, -0.4564354121685 * 0.5, -0.18257416784763 * 0.25)

SWEP.ViewModelPunchPitchMultiplier = 0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09

SWEP.ViewModelPunch_MaxVertialOffset = 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights = 1.95
SWEP.ViewModelPunch_VertialMultiplier = 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights = 0.25

SWEP.ViewModelPunchYawMultiplier = 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.25

local onevec = Vector(1, 1, 1)

local function RBP(vm)
	local bc = vm:GetBoneCount()
	if not bc or bc <= 0 then return end

	for i = 0, bc do
		vm:ManipulateBoneScale(i, onevec)
		vm:ManipulateBoneAngles(i, angle_zero)
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

function SWEP:ApplyViewModelModifications()
	local self2 = self:GetTable()
	if not self2.VMIV(self) then return end

	local vm = self2.OwnerViewModel

	local bgcount = #(vm:GetBodyGroups() or {})
	local ViewModelBodygroups = self2.GetStatRawL(self, "ViewModelBodygroups")
	local bgt = ViewModelBodygroups or self2.Bodygroups or {}

	for i = 0, bgcount - 1 do
		vm:SetBodygroup(i, bgt[i] or 0)
	end

	local skinind = self2.GetStatL(self, "Skin")

	if skinind and isnumber(skinind) then
		vm:SetSkin(skinind)
		self:SetSkin(skinind)
	end

	self2.ClearMaterialCache(self)
end

function SWEP:ResetViewModelModifications()
	local self2 = self:GetTable()
	if not self2.VMIV(self) then return end

	local vm = self2.OwnerViewModel

	RBP(vm)

	vm:SetSkin(0)

	local matcount = #(vm:GetMaterials() or {})

	for i = 0, matcount do
		vm:SetSubMaterial(i, "")
	end

	for i = 0, #(vm:GetBodyGroups() or {}) - 1 do
		vm:SetBodygroup(i, 0)
	end
end