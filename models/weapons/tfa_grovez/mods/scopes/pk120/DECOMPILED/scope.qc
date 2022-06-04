//SCALE
$scale 37.5

//MODELNAME
$modelname "model.mdl"

//BODYGROUPS
$bodygroup "scope"
{
	studio "scope.smd"
}

//ZALOOPA
$surfaceprop "default"
$contents "solid"
$illumposition 0 0 0

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/scopes/pk120/"

//ATTACHMENTS
$attachment "scope" "mod_scope" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_scope" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_lens" "mod_scope" 0.000000 1.656263 1.773900 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_reticle" "mod_scope" 0.000000 -0.770362 1.773900 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
    
//BONEMERGE
$bonemerge "mod_scope"
$bonemerge "mod_scope_lens"
$bonemerge "mod_scope_reticle"

//IDLE
$sequence "idle" {
	"scope.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}