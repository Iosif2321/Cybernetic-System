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

function Assert-NotRegex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
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
Assert-Contains $postInit 'PHEN_CS_CSS_CloseRadius = 10;' 'Argus must always render close contacts inside 10 meters.'
Assert-Contains $postInit 'PHEN_CS_CSS_NearFOVRange = 100;' 'Argus must use the wider near-view cone out to 100 meters.'
Assert-Contains $postInit 'PHEN_CS_CSS_NearFOVDegrees = 110;' 'Argus near-view cone must be 110 degrees.'
Assert-Contains $postInit 'PHEN_CS_CSS_NearFOVDot = cos (PHEN_CS_CSS_NearFOVDegrees / 2);' 'Argus near-view cone must derive its dot threshold from 110 degrees.'
Assert-Contains $postInit 'PHEN_CS_CSS_RadarScaleLevels' 'Combat Sensor Suite radar scale levels are missing.'
Assert-Contains $postInit 'PHEN_CS_CSS_MinAimSolutionDistance = 15;' 'Aim prediction must ignore false near-self intersections.'
Assert-Contains $postInit 'PHEN_CS_CSS_AimSolution' 'Combat Sensor Suite pre-fire aim solution state is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_start' 'Combat Sensor Suite runtime start function is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateHud' 'Combat Sensor Suite HUD update function is missing.'
Assert-Contains $postInit 'addMissionEventHandler ["Draw3D"' 'Combat Sensor Suite Draw3D handler is missing.'
Assert-Contains $postInit 'allMines' 'Mine detection does not scan Arma mine objects.'

Assert-Contains $postInit 'worldToScreen' 'Combat Sensor Suite must screen-gate 3D markers with worldToScreen.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getViewDirection' 'Combat Sensor Suite must centralize unit-view direction selection.'
Assert-Contains $postInit 'eyeDirection _unit' 'Combat Sensor Suite FOV gating must use the implanted unit view direction.'
Assert-NotRegex $postInit 'PHEN_CS_fnc_CSS_isMarkerVisible\s*=\s*\{[\s\S]*positionCameraToWorld' 'Marker visibility must not use the active render/Zeus camera as the logical FOV source.'
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
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAimRay' 'Aim prediction must centralize weapon/camera aim-ray selection.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getMuzzleCfg' 'Aim prediction must resolve weapon muzzle config before reading speed data.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getBallisticData' 'Aim prediction must centralize weapon/magazine/ammo ballistic data.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_isAimHitValid' 'Aim prediction must validate impact surfaces before drawing markers.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getZeroDistance' 'Aim prediction must normalize currentZeroing output before using it.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyZeroing' 'Aim prediction must apply zeroing to the simulated projectile direction.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_isLauncherWeapon' 'Aim prediction must classify launchers and low-speed launcher-like weapons separately.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyNativeFocusState' 'Argus focus must use the native zoomTemp action state instead of a scripted camera.'
Assert-Contains $postInit 'actionKeysNamesArray "zoomTemp"' 'Argus focus HUD must expose the player-bound native focus key names.'
Assert-Contains $postInit 'secondaryWeapon _unit' 'Aim prediction must include launcher/secondary weapons such as RPGs.'

Assert-Contains $settings 'PHEN_CS_CSS_AllyMarkerScale' 'Missing CBA setting for per-client Argus allied marker scale.'
Assert-Contains $settings 'PHEN_CS_CSS_MineMarkerScale' 'Missing CBA setting for per-client Argus mine marker scale.'
Assert-Contains $settings 'PHEN_CS_CSS_HudScale' 'Missing CBA setting for per-client Argus HUD/radar scale.'
Assert-Regex $settings '"PHEN_CS_CSS_AllyMarkerScale"\s*,\s*"SLIDER"[\s\S]*\[0\.25,\s*2,\s*1,\s*2\][\s\S]*\n\s*0,' 'Argus allied marker scale must be a local 0.25-2.00 slider with default 1.00.'
Assert-Regex $settings '"PHEN_CS_CSS_MineMarkerScale"\s*,\s*"SLIDER"[\s\S]*\[0\.25,\s*2,\s*1,\s*2\][\s\S]*\n\s*0,' 'Argus mine marker scale must be a local 0.25-2.00 slider with default 1.00.'
Assert-Regex $settings '"PHEN_CS_CSS_HudScale"\s*,\s*"SLIDER"[\s\S]*\[0\.5,\s*2,\s*1,\s*2\][\s\S]*\n\s*0,' 'Argus HUD scale must be a local 0.50-2.00 slider with default 1.00.'

Assert-Regex $postInit 'PHEN_CS_CSS_FriendContacts\s*=\s*[^;]*call\s+PHEN_CS_fnc_CSS_filterVisibleContacts' 'Friend contact cache must be filtered by the view/visibility pipeline.'
Assert-Regex $postInit 'PHEN_CS_CSS_MineContacts\s*=\s*[^;]*call\s+PHEN_CS_fnc_CSS_filterVisibleContacts' 'Mine contact cache must be filtered by the view/visibility pipeline.'
Assert-Regex $postInit 'private\s+_distance\s*=\s*getPosASL _unit distance _targetASL;[\s\S]*if\s*\(_distance <= PHEN_CS_CSS_CloseRadius\)\s*exitWith\s*\{\s*true\s*\};' 'Marker visibility must bypass angle/screen checks for contacts inside 10 meters.'
Assert-Regex $postInit 'if\s*\(_distance <= PHEN_CS_CSS_NearFOVRange && \{ _forwardDot < PHEN_CS_CSS_NearFOVDot \}\)\s*exitWith\s*\{\s*false\s*\};' 'Marker visibility must use a 110-degree cone inside 100 meters.'
Assert-Regex $postInit 'if\s*\(_distance > PHEN_CS_CSS_NearFOVRange\)\s*then\s*\{[\s\S]*PHEN_CS_CSS_FarFOVDot' 'Markers beyond 100 meters must use the far-view cone.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_draw3D\s*=\s*\{[\s\S]*PHEN_CS_fnc_CSS_isMarkerVisible[\s\S]*drawIcon3D' 'Draw3D must gate marker rendering before drawIcon3D.'
Assert-Regex $postInit 'format \["%1 %2 %3m"' '3D labels must include classification, display label, and distance.'
Assert-Regex $postInit 'private\s+_allyMarkerScale\s*=\s*\(\(missionNamespace getVariable \["PHEN_CS_CSS_AllyMarkerScale", 1\]\) max 0\.25\) min 2;' 'Draw3D must read and clamp the allied marker scale.'
Assert-Regex $postInit 'private\s+_mineMarkerScale\s*=\s*\(\(missionNamespace getVariable \["PHEN_CS_CSS_MineMarkerScale", 1\]\) max 0\.25\) min 2;' 'Draw3D must read and clamp the mine marker scale.'
Assert-Regex $postInit 'linearConversion \[0, PHEN_CS_CSS_AllyRange, _distance, 0\.95, 0\.23, true\]\) \* _sizeFactor \* _allyMarkerScale' 'Allied 3D icon size must apply the allied marker scale.'
Assert-Regex $postInit '0\.75 \* _mineMarkerScale' 'Mine 3D icon size must apply the mine marker scale.'
Assert-Regex $postInit 'private\s+_hudScale\s*=\s*\(\(missionNamespace getVariable \["PHEN_CS_CSS_HudScale", 1\]\) max 0\.5\) min 2;' 'Argus HUD/radar must read and clamp the local HUD scale.'
Assert-Regex $postInit 'private\s+_panelW\s*=\s*\(0\.22 \* _hudScale\) min 0\.34;' 'Argus HUD width must be capped so max scale does not push text off-screen.'
Assert-Regex $postInit 'private\s+_textScale\s*=\s*0\.88 \+ \(\(_hudScale - 1\) \* 0\.12\);' 'Argus HUD text must scale more conservatively than the panel.'
Assert-Regex $postInit 'PHEN_CS_CSS_RadarContacts = PHEN_CS_CSS_FriendContacts apply \{ _x # 0 \};' 'Argus radar must use the same visible-contact cache as 3D markers.'
Assert-Contains $postInit 'PHEN_CS_CSS_RadarRingFractions = [0.5,1];' 'Argus minimap must declare half/full range ring fractions.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateRadarRings' 'Argus minimap must update range ring controls as part of the HUD layout.'
Assert-Contains $postInit 'PHEN_CS_CSS_RadarRing_%1_%2' 'Argus minimap range rings must be stored as reusable UI controls.'
Assert-Regex $postInit 'ctrlCreate \["RscPictureKeepAspect", -1\]' 'Argus minimap contacts must use picture controls, not plain square text controls.'
Assert-Regex $postInit 'ctrlSetAngle \[_headingAngle, 0\.5, 0\.5\]' 'Argus minimap contact icons must rotate to show unit facing.'
Assert-Regex $postInit 'ctrlSetText _icon' 'Argus minimap contacts must use class-specific marker icons.'
Assert-Regex $postInit 'ctrlSetTextColor _color' 'Argus minimap contact icons must keep class-specific colors.'
Assert-Regex $postInit 'private\s+_relativeBearing\s*=\s*\(_unit getDir _contact\) - _bearing;' 'Argus minimap must use heading-up relative bearing from the local player.'
Assert-Regex $postInit 'private\s+_iconRadius\s*=\s*\(_radius - \(_dotSize \* 0\.55\)\) max \(_radius \* 0\.2\);' 'Argus minimap must keep rotated icons inside the visible radar radius.'
Assert-NotContains $postInit 'PHEN_CS_CSS_RadarNose' 'Argus minimap must not draw a second nose/arrow layer over the map-style unit icon.'
Assert-NotContains $postInit 'arrow2_ca.paa' 'Argus minimap must not overlay separate arrow textures on top of map-style contact icons.'

Assert-Regex $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*call\s+PHEN_CS_fnc_CSS_getAimRay[\s\S]*call\s+PHEN_CS_fnc_CSS_getBallisticData' 'Aim prediction must build a config-driven live aim solution.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getAimRay\s*=\s*\{[\s\S]*eyePos _unit[\s\S]*weaponDirection _weapon[\s\S]*_fromWeapon' 'Aim prediction must use stable weaponDirection/eyePos data instead of drifting render-camera-only data.'
Assert-Regex $postInit 'if\s*\(_fromWeapon\)\s*then\s*\{\s*_sightDir\s*\}\s*else\s*\{ \[_sightDir, _speed, _zeroDistance, _gravityCoef\] call PHEN_CS_fnc_CSS_applyZeroing \}' 'Aim prediction must not double-apply zeroing when Arma provides weaponDirection.'
Assert-NotContains $postInit 'if (_isLauncher) then { _maxTime = 12; };' 'Launcher prediction must not use a hardcoded long-flight branch as if rockets were solved accurately.'
Assert-Contains $postInit 'timeToLive' 'Aim prediction must respect ammo timeToLive when bounding simulation.'
Assert-Contains $postInit 'artilleryLock' 'Aim prediction must account for artillery ammo airFriction behavior.'
Assert-Contains $postInit '_weaponSpeed < 0' 'Aim prediction must support negative weapon initSpeed as a magazine-speed multiplier.'
Assert-Contains $postInit '"shotmissile"' 'Aim prediction must detect missile simulation and avoid false launcher impact markers.'
Assert-Contains $postInit '"NO SOLUTION"' 'Aim prediction must report no solution instead of drawing a false launcher marker.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_isAimHitValid\s*=\s*\{[\s\S]*PHEN_CS_CSS_MinAimSolutionDistance' 'Aim prediction must skip false intersections too close to the player through hit validation.'
Assert-NotRegex $postInit 'if\s*!\(_weapon in \[primaryWeapon _unit, handgunWeapon _unit\]\)' 'Aim prediction must not reject RPGs/launchers with a primary/handgun-only filter.'
Assert-NotRegex $postInit 'private\s+_dir\s*=\s*vectorNormalized\s*\(_unit weaponDirection _weapon\);[\s\S]*private\s+_startASL\s*=\s*\(eyePos _unit\)' 'Aim prediction still uses the old eyePos/weaponDirection-only path.'
Assert-NotRegex $postInit 'PHEN_CS_fnc_CSS_getAimRay\s*=\s*\{[\s\S]*positionCameraToWorld \[0,0,0\][\s\S]*if \(\(_weaponVector vectorDotProduct _cameraDir\) < 0\.35\)' 'Aim prediction must not drift from camera-first aim-ray selection.'

Assert-NotContains $postInit 'camCreate' 'Argus combat focus must not create a scripted camera.'
Assert-NotContains $postInit 'cameraEffect ["Internal","Back"]' 'Argus combat focus must not switch the player view to a scripted camera.'
Assert-NotContains $postInit 'camSetFov' 'Argus combat focus must not fake native focus by setting scripted camera FOV.'
Assert-NotContains $postInit 'PHEN_CS_CSS_ZoomCamera' 'Argus combat focus must not keep a camera object in mission state.'
Assert-NotContains $postInit 'PHEN_CS_CSS_ZoomPFH' 'Argus combat focus must not run a camera-follow per-frame handler.'

Assert-Contains $stringtable 'STR_PHEN_CS_CBA_SUB_OCULAR_4' 'Stringtable is missing Ocular 4 subcategory localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_RADAR_SCALE' 'Stringtable is missing Combat Sensor radar scale key localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_RADAR_SCALE_TT' 'Stringtable is missing Combat Sensor radar scale key tooltip localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_ALLY_MARKER_SCALE' 'Stringtable is missing Argus allied marker scale localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_ALLY_MARKER_SCALE_TT' 'Stringtable is missing Argus allied marker scale tooltip localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_MINE_MARKER_SCALE' 'Stringtable is missing Argus mine marker scale localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_MINE_MARKER_SCALE_TT' 'Stringtable is missing Argus mine marker scale tooltip localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_HUD_SCALE' 'Stringtable is missing Argus HUD scale localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_CSS_HUD_SCALE_TT' 'Stringtable is missing Argus HUD scale tooltip localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_FOCUS_STATUS' 'Stringtable is missing Argus native focus status key localization.'
Assert-Contains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_FOCUS_STATUS_TT' 'Stringtable is missing Argus native focus status tooltip localization.'
Assert-NotContains $stringtable 'actual camera zoom' 'Argus localization must not describe a scripted actual camera zoom.'

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
