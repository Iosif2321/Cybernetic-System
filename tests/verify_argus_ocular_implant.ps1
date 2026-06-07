param(
    [string]$Root = ''
)

if ([string]::IsNullOrWhiteSpace($Root)) {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir) -and -not [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    if (-not [string]::IsNullOrWhiteSpace($scriptDir)) {
        $Root = (Resolve-Path -LiteralPath (Join-Path $scriptDir '..')).Path
    } else {
        $Root = (Get-Location).Path
    }
}

$sourceRoot = Join-Path $Root 'source\PHEN_Cybernetics'
if (-not (Test-Path -LiteralPath $sourceRoot)) {
    $sourceRoot = Join-Path $Root '_unpacked\PHEN_Cybernetics'
}

$workspaceRoot = (Resolve-Path -LiteralPath (Join-Path $Root '..\..')).Path
$unpackedRoot = Join-Path $workspaceRoot '_unpacked\PHEN_Cybernetics'

$settingsPath = Join-Path $sourceRoot 'bootstrap\Settings_PreInit.sqf'
$preInitPath = Join-Path $sourceRoot 'bootstrap\XEH_PreInit.sqf'
$postInitPath = Join-Path $sourceRoot 'bootstrap\XEH_postInit.sqf'
$stringtablePath = Join-Path $sourceRoot 'Stringtable.xml'
$configPath = Join-Path $sourceRoot 'config.cpp'
$readmePath = Join-Path $Root 'README.md'
if (-not (Test-Path -LiteralPath $configPath)) {
    $configPath = Join-Path $unpackedRoot 'config.cpp'
}

$settings = Get-Content -LiteralPath $settingsPath -Raw
$preInit = Get-Content -LiteralPath $preInitPath -Raw
$postInit = Get-Content -LiteralPath $postInitPath -Raw
$stringtable = Get-Content -LiteralPath $stringtablePath -Raw
$readme = if (Test-Path -LiteralPath $readmePath) { Get-Content -LiteralPath $readmePath -Raw } else { '' }
$config = if (Test-Path -LiteralPath $configPath) { Get-Content -LiteralPath $configPath -Raw } else { '' }
$combined = $settings + "`n" + $preInit + "`n" + $postInit + "`n" + $stringtable + "`n" + $config + "`n" + $readme
$errors = New-Object System.Collections.Generic.List[string]

function Assert-Contains {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Message
    )

    if (-not $Text.Contains($Needle)) {
        $script:errors.Add($Message)
    }
}

function Assert-NotContains {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Message
    )

    if ($Text.Contains($Needle)) {
        $script:errors.Add($Message)
    }
}

function Assert-Regex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if (-not ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline))) {
        $script:errors.Add($Message)
    }
}

Assert-Contains $settings 'PHEN_CS_Cybernetic_OCULAR_ITEM_3_Name' 'Missing CBA name setting for PHEN_CS_Cybernetic_OCULAR_ITEM_3.'
Assert-Contains $settings 'Argus Combat Optics Mk.IV' 'Missing Argus Combat Optics Mk.IV default name.'
Assert-Contains $settings 'PHEN_CS_Cybernetic_OCULAR_ITEM_3_Effects' 'Missing CBA effects setting for PHEN_CS_Cybernetic_OCULAR_ITEM_3.'
Assert-Contains $settings '["combatSensorSuite", true]' 'Argus effects do not enable combatSensorSuite.'

Assert-Contains $preInit 'PHEN_CS_Cybernetic_OCULAR_ITEM_3 = [' 'Missing item array for PHEN_CS_Cybernetic_OCULAR_ITEM_3.'
Assert-Contains $preInit 'PHEN_CS_Cybernetic_OCULAR_ITEM_3,' 'Argus item is not included in the master item list.'
Assert-Contains $preInit 'PHEN_CS_Cybernetic_OCULAR_ITEM_3#0' 'Argus item is not included in the ZEN display list.'
Assert-Contains $preInit '"PHEN_CS_Cybernetic_OCULAR_ITEM_3"' 'Argus item ID is not included in PHEN_CS_Cybernetic_ItemIDs.'
Assert-Contains $preInit '// OCULAR (4)' 'Ocular category map was not expanded to four items.'
Assert-Contains $preInit 'case (_effectName isEqualTo "combatSensorSuite")' 'combatSensorSuite effect is not parsed by the cyberware handler.'
Assert-Contains $preInit 'PHEN_CS_Abillity_CombatSensorSuite' 'Combat Sensor Suite ability variable is not applied.'
Assert-Contains $preInit '"PHEN_CS_LowLightOptics_MkIV"' 'Mk.IV cyber NVG class is not enforced by ocular logic.'

Assert-Contains $postInit 'PHEN_CS_CSS_MineRadius = 50;' 'Mine detection radius must be 50 meters.'
Assert-Contains $postInit 'PHEN_CS_CSS_AllyRange = 1000;' 'Allied unit highlight range must be 1000 meters.'
Assert-Contains $postInit 'PHEN_CS_CSS_RadarScaleLevels' 'Combat Sensor Suite radar scale levels are missing.'
Assert-Contains $postInit 'PHEN_CS_CSS_AimSolution' 'Combat Sensor Suite pre-fire aim solution state is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_start' 'Combat Sensor Suite runtime start function is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateHud' 'Combat Sensor Suite HUD update function is missing.'
Assert-Contains $postInit 'addMissionEventHandler ["Draw3D"' 'Combat Sensor Suite Draw3D handler is missing.'
Assert-Contains $postInit 'allMines' 'Mine detection does not scan Arma mine objects.'

Assert-Contains $postInit 'worldToScreen' 'Combat Sensor Suite must screen-gate 3D markers with worldToScreen.'
Assert-Contains $postInit 'getCameraViewDirection' 'Combat Sensor Suite must use the current camera direction for FOV gating.'
Assert-Contains $postInit 'positionCameraToWorld [0,0,0]' 'Combat Sensor Suite must use the render camera origin for view gating.'
Assert-Contains $postInit 'checkVisibility' 'Combat Sensor Suite must visibility-gate markers.'
Assert-Contains $postInit '"VIEW"' 'Combat Sensor Suite visibility checks must use VIEW LOD.'
Assert-Contains $postInit 'weaponState _unit' 'Pre-fire prediction must read the current weapon state.'
Assert-Contains $postInit 'weaponDirection _weapon' 'Pre-fire prediction must use current weaponDirection.'
Assert-Contains $postInit 'lineIntersectsSurfaces' 'Pre-fire prediction must raycast/intersect the predicted path.'
Assert-Contains $postInit 'currentZeroing [_weapon, _muzzle]' 'Pre-fire prediction must read current zeroing.'
Assert-Contains $postInit 'inputAction "zoomTemp"' 'Argus must observe native view focus instead of selecting a binocular weapon.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_classifyContact' 'Combat Sensor Suite contact classifier is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_filterVisibleContacts' 'Combat Sensor Suite visible-contact filter is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction' 'Combat Sensor Suite pre-fire prediction updater is missing.'

Assert-Regex $postInit 'PHEN_CS_CSS_FriendContacts\s*=\s*[^;]*call\s+PHEN_CS_fnc_CSS_filterVisibleContacts' 'Friend contact cache must be filtered by the view/visibility pipeline.'
Assert-Regex $postInit 'PHEN_CS_CSS_MineContacts\s*=\s*[^;]*call\s+PHEN_CS_fnc_CSS_filterVisibleContacts' 'Mine contact cache must be filtered by the view/visibility pipeline.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_draw3D\s*=\s*\{[\s\S]*PHEN_CS_fnc_CSS_isMarkerVisible[\s\S]*drawIcon3D' 'Draw3D must gate marker rendering before drawIcon3D.'
Assert-Regex $postInit 'format \["%1 %2 %3m"' '3D labels must include classification, display label, and distance.'

Assert-Contains $stringtable 'STR_PHEN_CS_CBA_SUB_OCULAR_4' 'Stringtable is missing Ocular 4 subcategory localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_RADAR_SCALE' 'Stringtable is missing Combat Sensor radar scale key localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_RADAR_SCALE_TT' 'Stringtable is missing Combat Sensor radar scale key tooltip localization.'

if ($config -ne '') {
    Assert-Contains $config 'class PHEN_CS_Item_LowLightOptics_MkIV' 'Config is missing PHEN_CS_Item_LowLightOptics_MkIV holder.'
    Assert-Contains $config 'class PHEN_CS_LowLightOptics_MkIV' 'Config is missing PHEN_CS_LowLightOptics_MkIV NVG weapon.'
    Assert-Contains $config '"PHEN_CS_LowLightOptics_MkIV"' 'CfgPatches weapons[] does not list PHEN_CS_LowLightOptics_MkIV.'
}

Assert-NotContains $combined 'PHEN_CS_ArgusIntegratedBinocular' 'Argus must not define, add, remove, select, document, or test a held binocular weapon.'
Assert-NotContains $combined 'class ArgusStepZoom' 'Removed Argus binocular OpticsModes/ArgusStepZoom block is still present.'
Assert-NotContains $combined 'discretefov[]={0.25,0.125,0.0625,0.03125};' 'Removed Argus binocular stepped FOV config is still present.'
Assert-NotContains $postInit 'PHEN_CS_CSS_AddedBinocular' 'Runtime still tracks a generated binocular weapon.'
Assert-NotContains $postInit 'addEventHandler ["FiredMan"' 'Argus must not use FiredMan actual-projectile tracking for its prediction marker.'
Assert-NotContains $postInit 'PHEN_CS_fnc_CSS_onFired' 'Argus actual-impact FiredMan handler function is still present.'
Assert-NotContains $postInit 'PHEN_CS_fnc_CSS_registerFiredEH' 'Argus FiredMan registration function is still present.'
Assert-NotContains $postInit '_projectile' 'Argus prediction must not be based on a fired projectile object.'
Assert-NotContains $preInit 'selectWeapon' 'Combat Sensor keybind must not switch the player weapon.'

if ($errors.Count -gt 0) {
    Write-Host 'Argus ocular implant verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'Argus ocular implant verification passed.'
