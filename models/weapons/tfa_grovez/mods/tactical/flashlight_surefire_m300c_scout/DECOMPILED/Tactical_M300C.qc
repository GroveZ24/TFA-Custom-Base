//SCALE
$scale 37.5

//ORIGIN
//$origin 0 0 0 0

//MODELNAME
$modelname "weapons\tfa_grovez\mods\tactical\flashlight_surefire_m300c_scout\tactical.mdl"

//MODEL
$model "Tactical" "Tactical.smd"

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
$mostlyopaque

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/tactical/flashlight_surefire_m300c/"

//ATTACHMENTS
$attachment "tactical" "mod_tactical" 0 0 0 rotate 0 0 0
$attachment "tactical_lightsource" "mod_tactical_lightsource" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_tactical" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_tactical_lightsource" "mod_tactical" 0.000000 2.285700 0.571537 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_tactical"
$bonemerge "mod_tactical_lightsource"

//IDLE
$sequence idle "Tactical.smd"