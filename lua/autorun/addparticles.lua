if CLIENT then
	game.AddParticles("particles/ayykyu_muzzleflashes.pcf")
	CreateClientConVar("fas2_flashes_dynlight", 1)
end

if SERVER then
	game.AddParticles("particles/ayykyu_muzzleflashes.pcf")
end