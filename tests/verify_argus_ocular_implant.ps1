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
if (-not (Test-Path -LiteralPath $configPath)) {
    $configPath = Join-Path $unpackedRoot 'config.cpp'
}

$settings = Get-Content -LiteralPath $settingsPath -Raw
$preInit = Get-Content -LiteralPath $preInitPath -Raw
$postInit = Get-Content -LiteralPath $postInitPath -Raw
$stringtable = Get-Content -LiteralPath $stringtablePath -Raw
$config = if (Test-Path -LiteralPath $configPath) { Get-Content -LiteralPath $configPath -Raw } else { '' }
$combined = $settings + "`n" + $preInit + "`n" + $postInit + "`n" + $stringtable + "`n" + $config
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
Assert-Contains $preInit 'selectWeapon "PHEN_CS_ArgusIntegratedBinocular"' 'Combat Sensor zoom key does not select the integrated Argus binocular.'

Assert-Contains $postInit 'PHEN_CS_CSS_MineRadius = 50;' 'Mine detection radius must be 50 meters.'
Assert-Contains $postInit 'PHEN_CS_CSS_AllyRange = 1000;' 'Allied unit highlight range must be 1000 meters.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_start' 'Combat Sensor Suite runtime start function is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateHud' 'Combat Sensor Suite HUD update function is missing.'
Assert-Contains $postInit 'addMissionEventHandler ["Draw3D"' 'Combat Sensor Suite Draw3D handler is missing.'
Assert-Contains $postInit 'addEventHandler ["FiredMan"' 'Combat Sensor Suite FiredMan handler is missing.'
Assert-Contains $postInit 'PHEN_CS_ArgusIntegratedBinocular' 'Integrated binocular class is not managed by runtime.'
Assert-Contains $postInit 'allMines' 'Mine detection does not scan Arma mine objects.'

Assert-Contains $stringtable 'STR_PHEN_CS_CBA_SUB_OCULAR_4' 'Stringtable is missing Ocular 4 subcategory localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_ZOOM' 'Stringtable is missing Combat Sensor zoom key localization.'

if ($config -ne '') {
    Assert-Contains $config 'class PHEN_CS_Item_LowLightOptics_MkIV' 'Config is missing PHEN_CS_Item_LowLightOptics_MkIV holder.'
    Assert-Contains $config 'class PHEN_CS_LowLightOptics_MkIV' 'Config is missing PHEN_CS_LowLightOptics_MkIV NVG weapon.'
    Assert-Contains $config 'class PHEN_CS_ArgusIntegratedBinocular' 'Config is missing PHEN_CS_ArgusIntegratedBinocular.'
    Assert-Contains $config '"PHEN_CS_LowLightOptics_MkIV"' 'CfgPatches weapons[] does not list PHEN_CS_LowLightOptics_MkIV.'
    Assert-Contains $config '"PHEN_CS_ArgusIntegratedBinocular"' 'CfgPatches weapons[] does not list PHEN_CS_ArgusIntegratedBinocular.'
    Assert-Contains $config 'discretefov[]={0.25,0.125,0.0625,0.03125};' 'Argus binocular is missing stepped FOV zoom configuration.'
}

if ($errors.Count -gt 0) {
    Write-Host 'Argus ocular implant verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'Argus ocular implant verification passed.'
