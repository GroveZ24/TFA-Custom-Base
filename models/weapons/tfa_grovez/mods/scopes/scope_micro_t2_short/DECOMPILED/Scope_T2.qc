//SCALE
$scale 37.5

//ORIGIN
//$origin 0 0 0 0

//MODELNAME
$modelname "weapons\tfa_grovez\mods\scopes\scope_micro_t2_short\scope.mdl"

//MODEL
$model "Scope" "Scope.smd"

//ZALOOPA
$surfaceprop "default"
$contents "solid"
$illumposition 0 0 0
$mostlyopaque

//CDMATERIALS
$cdmaterials "models/weapons/tfa_grovez/mods/scopes/scope_micro_t2/"

//ATTACHMENTS
$attachment "scope" "mod_scope" 0 0 0 rotate 0 0 0

//DEFINEBONE
$definebone "mod_scope" "" 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_lens" "mod_scope" 0.000000 1.768425 0.839625 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "mod_scope_reticle" "mod_scope" 0.000000 -0.413850 0.839625 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

//BONEMERGE
$bonemerge "mod_scope"
$bonemerge "mod_scope_lens"
$bonemerge "mod_scope_reticle"

//IDLE
$sequence idle "Scope.smd"