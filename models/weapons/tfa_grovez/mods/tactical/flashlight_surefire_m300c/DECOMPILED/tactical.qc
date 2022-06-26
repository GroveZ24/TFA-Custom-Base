//SCALE
$scale 37.5

//MODELNAME
$modelname "model.mdl"

//BODYGROUPS
$bodygroup "Tactical"
{
	studio "tactical_1.smd"
	studio "tactical_2.smd"
}

//TEXTUREGROUPS
$texturegroup skin
{
	{
		"M300C"
		"Surefire_Scout_Mount"
	}
	{
		"M300C_Tan"
		"Surefire_Scout_Mount_Tan"
	}
}

//ZALOOPA
$surfaceprop "default"
$contents "solid"
$illumposition 0 0 0

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/tactical/flashlight_surefire_m300c/"

//ATTACHMENTS
$attachment "tactical" "mod_tactical" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_tactical" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_tactical"

//IDLE
$sequence idle "tactical_1.smd"