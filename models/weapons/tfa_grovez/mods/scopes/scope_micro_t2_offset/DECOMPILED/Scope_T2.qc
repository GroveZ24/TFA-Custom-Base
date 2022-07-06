//SCALE
$scale 37.5

//ORIGIN
//$origin 0 0 0 0

//MODELNAME
$modelname "weapons\tfa_grovez\mods\scopes\scope_micro_t2_offset\scope.mdl"

//MODEL
$model "Scope" "Scope.smd"

//ZALOOPA
$surfaceprop "default"
$contents "solid"
$illumposition 0 0 0

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/scopes/scope_micro_t2/"

//ATTACHMENTS
$attachment "scope" "mod_scope" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_scope" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_lens" "mod_scope" -1.438650 1.907550 1.077000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_reticle" "mod_scope" -1.438650 -0.274725 1.077000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_scope"
$bonemerge "mod_scope_lens"
$bonemerge "mod_scope_reticle"

//IDLE
$sequence idle "Scope.smd"