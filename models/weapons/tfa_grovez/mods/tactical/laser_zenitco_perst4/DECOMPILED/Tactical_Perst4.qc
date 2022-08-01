//SCALE
$scale 37.5

//ORIGIN
//$origin 0 0 0 0

//MODELNAME
$modelname "weapons\tfa_grovez\mods\tactical\laser_zenitco_perst4\tactical.mdl"

//MODEL
$model "Tactical" "Tactical.smd"

//BODYGROUPS
$bodygroup "Mode"
{
	studio "Tactical_OFF.smd" // OFF
	studio "Tactical_V.smd" // VISIBLE LASER
	studio "Tactical_IR.smd" // IR LASER
}

//ZALOOPA
$surfaceprop "default"
$contents "solid"
$illumposition 0 0 0
$mostlyopaque

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/tactical/laser_zenitco_perst4/"

//ATTACHMENTS
$attachment "tactical" "mod_tactical" 0 0 0 rotate 0 0 0
$attachment "tactical_laserbeam" "tactical_laserbeam" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_tactical" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "tactical_laserbeam" "mod_tactical" 0.952125 2.705888 0.471938 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_tactical"
$bonemerge "tactical_laserbeam"

//IDLE
$sequence idle "Tactical.smd"