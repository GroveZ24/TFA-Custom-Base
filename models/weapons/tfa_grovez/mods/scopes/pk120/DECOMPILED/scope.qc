//SCALE
$scale 37.5

//MODELNAME
$modelname "model.mdl"

//BODYGROUPS
$model "Scope" "Scope.smd"

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
$definebone "mod_scope_lens" "mod_scope" 0.000000 1.444613 1.773900 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_reticle" "mod_scope" 0.000000 0.367125 1.773900 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_scope"
$bonemerge "mod_scope_lens"
$bonemerge "mod_scope_reticle"

//IDLE
$sequence idle "scope.smd"