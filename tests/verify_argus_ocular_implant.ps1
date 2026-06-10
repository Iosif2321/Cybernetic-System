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
$pboPath = Join-Path $Root 'addons\PHEN_Cybernetics.pbo'
if (-not (Test-Path -LiteralPath $configPath)) {
    $configPath = Join-Path $unpackedRoot 'config.cpp'
}

$settings = Get-Content -LiteralPath $settingsPath -Raw
$preInit = Get-Content -LiteralPath $preInitPath -Raw
$postInit = Get-Content -LiteralPath $postInitPath -Raw
$stringtable = Get-Content -LiteralPath $stringtablePath -Raw
$readme = if (Test-Path -LiteralPath $readmePath) { Get-Content -LiteralPath $readmePath -Raw } else { '' }
$config = if (Test-Path -LiteralPath $configPath) { Get-Content -LiteralPath $configPath -Raw } else { '' }
$runtimeCombined = $settings + "`n" + $preInit + "`n" + $postInit + "`n" + $stringtable + "`n" + $config
$combined = $runtimeCombined + "`n" + $readme
$pboPayload = if (Test-Path -LiteralPath $pboPath) {
    [System.Text.Encoding]::GetEncoding(28591).GetString([System.IO.File]::ReadAllBytes($pboPath))
} else {
    ''
}

function Get-TextBetween {
    param(
        [string]$Text,
        [string]$StartNeedle,
        [string]$EndNeedle
    )

    $start = $Text.IndexOf($StartNeedle)
    if ($start -lt 0) { return '' }
    $end = $Text.IndexOf($EndNeedle, $start + $StartNeedle.Length)
    if ($end -lt 0 -or $end -le $start) { return $Text.Substring($start) }
    return $Text.Substring($start, $end - $start)
}

$postShotRuntime = Get-TextBetween $postInit 'PHEN_CS_fnc_CSS_onFiredDebug' 'PHEN_CS_fnc_CSS_registerFiredDebugEH'
$postShotPbo = Get-TextBetween $pboPayload 'PHEN_CS_fnc_CSS_onFiredDebug' 'PHEN_CS_fnc_CSS_registerFiredDebugEH'
$errors = New-Object System.Collections.Generic.List[string]
if ([string]::IsNullOrEmpty($pboPayload)) {
    $errors.Add('Packed PBO addons\PHEN_Cybernetics.pbo is missing or empty.')
}

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
        [string]$Message,
        [string]$Anchor = ''
    )

    $scanText = $Text
    if (-not [string]::IsNullOrEmpty($Anchor)) {
        $anchorIndex = $Text.IndexOf($Anchor, [System.StringComparison]::Ordinal)
        if ($anchorIndex -lt 0) {
            return
        }

        $contextLength = 12000
        $start = [Math]::Max(0, $anchorIndex - $contextLength)
        $length = [Math]::Min($Text.Length - $start, ($contextLength * 2) + $Anchor.Length)
        $scanText = $Text.Substring($start, $length)
    }

    $options = [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    $timeout = [TimeSpan]::FromSeconds(3)
    try {
        $matched = [regex]::new($Pattern, $options, $timeout).IsMatch($scanText)
    } catch [System.Text.RegularExpressions.RegexMatchTimeoutException] {
        $script:errors.Add("Regex timed out while checking: $Message")
        return
    }

    if ($matched) {
        $script:errors.Add($Message)
    }
}

function Assert-RuntimeAndPboContains {
    param(
        [string]$Needle,
        [string]$Message
    )

    Assert-Contains $postInit $Needle "$Message (source runtime)"
    Assert-Contains $pboPayload $Needle "$Message (packed PBO)"
}

function Assert-RuntimeAndPboNotRegex {
    param(
        [string]$Pattern,
        [string]$Message,
        [string]$PboAnchor = ''
    )

    Assert-NotRegex $postInit $Pattern "$Message (source runtime)"
    Assert-NotRegex $pboPayload $Pattern "$Message (packed PBO)" $PboAnchor
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
Assert-Contains $postInit 'PHEN_CS_CSS_ImpactMatchTolerance = 75;' 'Post-shot telemetry must reject impact events that are too far from the traced projectile endpoint.'
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
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_classifyContact' 'Combat Sensor Suite contact classifier is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_filterVisibleContacts' 'Combat Sensor Suite visible-contact filter is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction' 'Combat Sensor Suite pre-fire prediction updater is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAimFrame' 'Aim prediction must centralize weapon/camera aim-frame selection.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAimOrigin' 'Aim prediction must resolve the trajectory origin explicitly.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAimDebugPayload' 'Aim prediction must build structured debug payloads.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getMuzzleCfg' 'Aim prediction must resolve weapon muzzle config before reading speed data.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getBallisticData' 'Aim prediction must centralize weapon/magazine/ammo ballistic data.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_isAimHitValid' 'Aim prediction must validate impact surfaces before drawing markers.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAimHitStatus' 'Aim prediction must return hit validation reasons for debug and no-solution states.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_allowRayFallback' 'Aim prediction must gate direct ray fallback through an explicit policy.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getAttachmentCoefs' 'Aim prediction must resolve attachment ballistic coefficients explicitly.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getWeaponSlot' 'Aim prediction must identify the active weapon slot explicitly.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getZeroDistance' 'Aim prediction must normalize currentZeroing output before using it.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyZeroing' 'Aim prediction must apply zeroing to the simulated projectile direction.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_shouldApplyZeroing' 'Aim prediction must gate manual zeroing through an explicit policy.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyAimCalibration' 'Aim prediction must be able to apply fired-projectile calibration profiles.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_storeShotCalibration' 'FiredMan telemetry must store reusable shot calibration data.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_calibrationWantsZeroing' 'Aim prediction must let fired-projectile calibration choose raw vs zeroed direction mode.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applySpeedCalibration' 'Aim prediction must reuse measured projectile speed when a calibration profile exists.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_measureDirectionError' 'FiredMan telemetry must measure raw/zeroed direction error against the real projectile velocity.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_isLauncherWeapon' 'Aim prediction must classify launchers and low-speed launcher-like weapons separately.'
Assert-Contains $postInit 'secondaryWeapon _unit' 'Aim prediction must include launcher/secondary weapons such as RPGs.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getProjectileFamily' 'Aim prediction must classify projectile families before selecting a solver.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getImpactEvaluation' 'Post-shot telemetry must classify impact events before reporting prediction accuracy.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getImpactEventPosition' 'Post-shot telemetry must extract the impact event position before trusting impact scoring.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_shouldReportPredictionError' 'Post-shot telemetry must suppress ordinary accuracy scoring for deflections and unsupported predictions.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getRocketAccel' 'Rocket prediction must use an explicit rocket acceleration helper instead of the bullet/shell drag path.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_setAimDebugState' 'Aim prediction must record debug reasons before clearing or drawing the marker.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_logAimDebug' 'Aim prediction debug state must be loggable under debug mode.'
Assert-Contains $postInit 'PHEN_CS_CSS_PostShotDebugState' 'Argus post-shot telemetry state is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_setPostShotDebugState' 'Argus post-shot telemetry setter is missing.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_logPostShotDebug' 'Argus post-shot telemetry logger is missing.'
Assert-Contains $postInit '[PHEN_CS][ArgusShot]' 'Argus post-shot telemetry must have a distinct RPT prefix.'
Assert-Contains $postInit 'impact_state_mismatch' 'Argus post-shot telemetry must exclude impact states that belong to a different projectile trace.'
Assert-Contains $postInit 'impact_position_unavailable' 'Argus post-shot telemetry must fail closed when a scoreable impact event has no extractable position.'
Assert-Contains $postInit 'trace_end_unavailable' 'Argus post-shot telemetry must fail closed when a scoreable impact event has no local projectile trace endpoint.'
Assert-Contains $postInit 'impactDistanceFromTraceEnd' 'Argus post-shot telemetry must log the distance between impact state and traced projectile endpoint.'
Assert-Contains $postInit 'impactPosASL' 'Argus post-shot telemetry must log the extracted impact position for mismatch diagnosis.'
Assert-Contains $postInit 'PHEN_CS_CSS_ShotCalibration' 'Argus must keep fired-projectile calibration profiles for pre-shot prediction correction.'
Assert-Contains $postInit 'PHEN_CS_CSS_LastProjectileImpactState' 'Argus must keep the latest projectile impact event state for debug validation.'

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

Assert-Regex $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*call\s+PHEN_CS_fnc_CSS_getBallisticData[\s\S]*call\s+PHEN_CS_fnc_CSS_getAimFrame' 'Aim prediction must build a config-driven live aim solution.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getAimFrame\s*=\s*\{[\s\S]*weaponDirection _weapon[\s\S]*call\s+PHEN_CS_fnc_CSS_getAimOrigin[\s\S]*originMethod[\s\S]*dirMethod' 'Aim prediction must expose origin/direction methods instead of returning an unlabeled ray tuple.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getAimFrame\s*=\s*\{[\s\S]*call\s+PHEN_CS_fnc_CSS_applyZeroing[\s\S]*zeroingApplied' 'Aim prediction must explicitly record when zeroing is applied to the simulated projectile direction.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*call\s+PHEN_CS_fnc_CSS_getShotCalibration[\s\S]*call\s+PHEN_CS_fnc_CSS_applySpeedCalibration[\s\S]*call\s+PHEN_CS_fnc_CSS_shouldApplyZeroing[\s\S]*call\s+PHEN_CS_fnc_CSS_calibrationWantsZeroing[\s\S]*call\s+PHEN_CS_fnc_CSS_applyAimCalibration' 'Aim prediction must load calibration before selecting zeroing, reuse measured speed, and apply stored shot calibration before integrating the path.'
Assert-NotContains $postInit 'if (_isLauncher) then { _maxTime = 12; };' 'Launcher prediction must not use a hardcoded long-flight branch as if rockets were solved accurately.'
Assert-Contains $postInit 'timeToLive' 'Aim prediction must respect ammo timeToLive when bounding simulation.'
Assert-Contains $postInit 'artilleryLock' 'Aim prediction must account for artillery ammo airFriction behavior.'
Assert-Contains $postInit '_weaponSpeed < 0' 'Aim prediction must support negative weapon initSpeed as a magazine-speed multiplier.'
Assert-Contains $postInit 'attachmentCoefs' 'Aim prediction debug payload must include attachment coefficient data.'
Assert-Contains $postInit '"shotrocket"' 'Aim prediction must explicitly classify unguided rocket simulation.'
Assert-Contains $postInit 'initTime' 'Rocket prediction must read ammo initTime.'
Assert-Contains $postInit 'thrustTime' 'Rocket prediction must read ammo thrustTime.'
Assert-Contains $postInit 'thrust' 'Rocket prediction must read ammo thrust.'
Assert-Contains $postInit 'maxSpeed' 'Rocket prediction must read ammo maxSpeed.'
Assert-Contains $postInit 'sideAirFriction' 'Rocket prediction must read ammo sideAirFriction.'
Assert-Contains $postInit '"shotmissile"' 'Aim prediction must detect missile simulation and avoid false launcher impact markers.'
Assert-Contains $postInit '"NO SOLUTION"' 'Aim prediction must report no solution instead of drawing a false launcher marker.'
Assert-Contains $postInit '"rocket_approx"' 'Rocket prediction must label unguided rocket points as approximate instead of bullet-accurate.'
Assert-Contains $postInit '"APPROX ROCKET"' 'Rocket prediction must expose an approximate rocket solution label.'
Assert-Contains $postInit '"predictionQuality"' 'Aim debug payload must report prediction quality for bullet/shell/rocket solver paths.'
Assert-Contains $postInit '"impactEvaluation"' 'Post-shot trace telemetry must report whether the impact is usable for accuracy scoring.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getAimHitStatus\s*=\s*\{[\s\S]*PHEN_CS_CSS_MinAimSolutionDistance' 'Aim prediction must skip false intersections too close to the player through hit validation.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_setAimDebugState\s*=\s*\{[\s\S]*PHEN_CS_CSS_AimDebugState\s*=\s*\[_reason, _data, diag_tickTime\]' 'Aim prediction debug state must store reason, data, and timestamp.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_logAimDebug\s*=\s*\{[\s\S]*missionNamespace getVariable \["PHEN_CS_DebugMode", false\]' 'Aim prediction logging must be gated by the existing debug mode setting.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*"rocket_approx"[\s\S]*PHEN_CS_CSS_AimSolution\s*=\s*\[_hit # 0,\s*diag_tickTime \+ 0\.35,\s*"rocket"' 'Unguided shotrocket launchers must produce an approximate rocket aim solution instead of launcher_no_solution.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*"launcher_no_solution"[\s\S]*"NO SOLUTION"' 'Unsupported launchers and missiles must still record a visible no-solution reason instead of silently clearing the marker.'
Assert-Regex $postInit 'while\s*\{\s*_i <= _maxSteps && \{ _hit isEqualTo \[\] \}[\s\S]*if \(_hitStatus # 0\) then \{[\s\S]*_hitReason = _hitStatus # 1;[\s\S]*_hit = _segHits # 0;' 'Aim prediction must stop on the first accepted ballistic intersection and keep the accepted hit reason.'
Assert-NotContains $postInit 'if (_hitStatus # 0) exitWith { _hit = _segHits # 0; };' 'Aim prediction must not keep integrating after storing an accepted hit through an inner exitWith.'
Assert-Contains $postInit '"no_valid_hit"' 'Aim prediction must record when no valid ray or ballistic hit is available.'
Assert-Contains $postInit '"originASL"' 'Aim debug payload must include the trajectory origin.'
Assert-Contains $postInit '"originMethod"' 'Aim debug payload must identify the origin source.'
Assert-Contains $postInit '"dir"' 'Aim debug payload must include the simulated direction.'
Assert-Contains $postInit '"dirMethod"' 'Aim debug payload must identify the direction source.'
Assert-Contains $postInit '"method"' 'Aim debug payload must record the selected solution method.'
Assert-Contains $postInit '"hitReason"' 'Aim debug payload must record hit validation reasons.'
Assert-NotRegex $postInit 'if\s*!\(_weapon in \[primaryWeapon _unit, handgunWeapon _unit\]\)' 'Aim prediction must not reject RPGs/launchers with a primary/handgun-only filter.'
Assert-NotRegex $postInit 'private\s+_dir\s*=\s*vectorNormalized\s*\(_unit weaponDirection _weapon\);[\s\S]*private\s+_startASL\s*=\s*\(eyePos _unit\)' 'Aim prediction still uses the old eyePos/weaponDirection-only path.'
Assert-RuntimeAndPboNotRegex 'PHEN_CS_fnc_CSS_getAimRay\s*=\s*\{[\s\S]*private\s+_startASL\s*=\s*eyePos _unit;[\s\S]*private\s+_weaponVector\s*=\s*vectorNormalized\s*\(_unit weaponDirection _weapon\);[\s\S]*\[_startASL,\s*_aimDir,\s*_weaponVector,\s*_fromWeapon\]' 'Aim prediction must not mix eyePos origin with weaponDirection direction in an unlabeled aim ray.' 'PHEN_CS_fnc_CSS_getAimRay'
Assert-RuntimeAndPboNotRegex 'if\s*!\(_hit isEqualTo \[\]\)\s*then\s*\{[\s\S]*PHEN_CS_CSS_AimSolution\s*=\s*\[_hit # 0[\s\S]*\}\s*else\s*\{[\s\S]*PHEN_CS_CSS_AimSolution\s*=\s*\[_rayPosASL,\s*diag_tickTime \+ 0\.35,\s*"ray"' 'Aim prediction must not fall back to a ray marker after a failed ballistic path without explicit fallback gating.' 'PHEN_CS_CSS_AimSolution'
Assert-RuntimeAndPboNotRegex 'private\s+_debugBase\s*=\s*\[[^\]]*_weapon[^\]]*_weaponDir[^\]]*\];' 'Aim debug payload must not be an unnamed positional _debugBase array.' 'private _debugBase'
Assert-NotRegex $postInit 'PHEN_CS_fnc_CSS_getAimRay\s*=\s*\{[\s\S]*positionCameraToWorld \[0,0,0\][\s\S]*if \(\(_weaponVector vectorDotProduct _cameraDir\) < 0\.35\)' 'Aim prediction must not drift from camera-first aim-ray selection.'

Assert-NotContains $postInit 'inputAction "zoomTemp"' 'Argus focus/zoom logic must be removed from runtime.'
Assert-NotContains $postInit 'actionKeysNamesArray "zoomTemp"' 'Argus focus/zoom key-name logic must be removed from runtime.'
Assert-NotContains $postInit 'PHEN_CS_CSS_FocusActive' 'Argus focus state must be removed from runtime.'
Assert-NotContains $postInit 'PHEN_CS_CSS_FocusKeyNames' 'Argus focus key cache must be removed from runtime.'
Assert-NotContains $postInit 'PHEN_CS_fnc_CSS_applyNativeFocusState' 'Argus native focus status function must be removed.'
Assert-NotContains $postInit 'PHEN_CS_fnc_CSS_showFocusStatus' 'Argus focus status HUD function must be removed.'
Assert-NotContains $postInit 'ARGUS NATIVE FOCUS' 'Argus focus status HUD text must be removed.'
Assert-NotContains $preInit 'PHEN_CS_CSS_FocusStatusKey' 'Argus focus status CBA keybind must be removed.'
Assert-NotContains $runtimeCombined 'zoomTemp' 'Argus runtime/config must not reference native focus/zoomTemp after focus removal.'
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
Assert-NotContains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_FOCUS_STATUS' 'Stringtable must not keep the removed Argus focus status key localization.'
Assert-NotContains $stringtable 'STR_PHEN_CS_CBA_KEY_CSS_FOCUS_STATUS_TT' 'Stringtable must not keep the removed Argus focus status tooltip localization.'
Assert-NotContains $stringtable 'actual camera zoom' 'Argus localization must not describe a scripted actual camera zoom.'

if ($config -ne '') {
    Assert-Contains $config 'class PHEN_CS_Item_LowLightOptics_MkIV' 'Config is missing PHEN_CS_Item_LowLightOptics_MkIV holder.'
    Assert-Contains $config 'class PHEN_CS_LowLightOptics_MkIV' 'Config is missing PHEN_CS_LowLightOptics_MkIV NVG weapon.'
    Assert-Contains $config '"PHEN_CS_LowLightOptics_MkIV"' 'CfgPatches weapons[] does not list PHEN_CS_LowLightOptics_MkIV.'
}

Assert-NotContains $runtimeCombined 'PHEN_CS_ArgusIntegratedBinocular' 'Argus runtime/config must not define, add, remove, or select a held binocular weapon.'
Assert-NotContains $runtimeCombined 'class ArgusStepZoom' 'Removed Argus binocular OpticsModes/ArgusStepZoom block is still present in runtime/config.'
Assert-NotContains $runtimeCombined 'discretefov[]={0.25,0.125,0.0625,0.03125};' 'Removed Argus binocular stepped FOV config is still present in runtime/config.'
Assert-NotContains $postInit 'PHEN_CS_CSS_AddedBinocular' 'Runtime still tracks a generated binocular weapon.'
Assert-Regex $postInit 'addEventHandler \["FiredMan"[\s\S]*PHEN_CS_fnc_CSS_onFiredDebug' 'Argus may use FiredMan only for isolated debug telemetry.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_onFiredDebug\s*=\s*\{[\s\S]*call\s+PHEN_CS_fnc_CSS_setPostShotDebugState' 'Argus actual-projectile telemetry must write post-shot debug state through the telemetry setter.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_onFiredDebug\s*=\s*\{[\s\S]*getShotInfo _projectile[\s\S]*call\s+PHEN_CS_fnc_CSS_storeShotCalibration' 'Argus FiredMan telemetry must compare real shotInfo/projectile velocity with the predicted aim frame and store calibration.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_onFiredDebug\s*=\s*\{[\s\S]*_rawAngle[\s\S]*_zeroedAngle[\s\S]*_chosenBaseMode\s*=\s*"raw"[\s\S]*PHEN_CS_fnc_CSS_storeShotCalibration' 'Argus FiredMan telemetry must choose the lower-error raw/zeroed direction basis before storing calibration.'
Assert-Contains $postInit 'calibrationBaseMode' 'Argus FiredMan telemetry must expose the chosen raw/zeroed calibration basis in debug state.'
Assert-Contains $postInit 'addEventHandler ["HitPart"' 'Argus projectile debug telemetry must capture direct hit event state.'
Assert-Contains $postInit 'addEventHandler ["Deflected"' 'Argus projectile debug telemetry must capture deflection event state.'
Assert-Contains $postInit 'addEventHandler ["Penetrated"' 'Argus projectile debug telemetry must capture penetration event state.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getImpactEvaluation\s*=\s*\{[\s\S]*"Deflected"[\s\S]*"excluded_deflected"' 'Deflected projectile events must be excluded from ordinary accuracy scoring.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_shouldReportPredictionError\s*=\s*\{[\s\S]*"scoreable"[\s\S]*"usable"' 'PredictionError must only be reported for scoreable usable impacts.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_onFiredDebug\s*=\s*\{[\s\S]*"impactEvaluation"[\s\S]*"predictionErrorUsable"' 'Argus trace_end telemetry must expose impact evaluation and whether predictionError is usable.'
Assert-Regex $postInit 'private\s+_predictionErrorTargetASL\s*=\s*if \(_impactPosASL isEqualType \[\][\s\S]*_predictionError = _predictedASL distance _predictionErrorTargetASL;' 'Argus trace_end telemetry must score predictionError against the verified impact position when available.'
Assert-Contains $postInit '"predictionErrorTargetASL"' 'Argus trace_end telemetry must log the point used for predictionError scoring.'
Assert-NotContains $postShotRuntime 'PHEN_CS_CSS_AimSolution =' 'Post-shot telemetry must not mutate the pre-shot prediction marker solution. (source runtime)'
Assert-NotContains $postShotPbo 'PHEN_CS_CSS_AimSolution =' 'Post-shot telemetry must not mutate the pre-shot prediction marker solution. (packed PBO)'
Assert-RuntimeAndPboNotRegex 'PHEN_CS_CSS_AimDebugState\s*=\s*PHEN_CS_CSS_PostShotDebugState|PHEN_CS_CSS_PostShotDebugState\s*=\s*PHEN_CS_CSS_AimDebugState' 'Pre-shot and post-shot debug states must not alias each other.'
Assert-NotContains $preInit 'selectWeapon' 'Combat Sensor keybind must not switch the player weapon.'

Assert-Contains $pboPayload 'PHEN_CS_CSS_AimDebugState' 'Packed PBO must contain the Argus aim debug state.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_logAimDebug' 'Packed PBO must contain the Argus aim debug logger.'
Assert-Contains $pboPayload '[PHEN_CS][ArgusAim]' 'Packed PBO must contain the Argus aim debug RPT prefix.'
Assert-Contains $pboPayload 'PHEN_CS_CSS_PostShotDebugState' 'Packed PBO must contain the Argus post-shot debug state.'
Assert-Contains $pboPayload '[PHEN_CS][ArgusShot]' 'Packed PBO must contain the Argus post-shot debug RPT prefix.'
Assert-Contains $pboPayload 'PHEN_CS_CSS_ShotCalibration' 'Packed PBO must contain fired-projectile calibration support.'
Assert-Contains $pboPayload 'getShotInfo _projectile' 'Packed PBO must contain real projectile shotInfo telemetry.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_getProjectileFamily' 'Packed PBO must contain projectile family selection.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_getRocketAccel' 'Packed PBO must contain the rocket acceleration helper.'
Assert-Contains $pboPayload 'rocket_approx' 'Packed PBO must contain approximate rocket prediction support.'
Assert-Contains $pboPayload 'impactEvaluation' 'Packed PBO must contain post-shot impact evaluation.'
Assert-NotContains $pboPayload 'zoomTemp' 'Packed PBO must not contain removed native focus/zoomTemp references.'
Assert-NotContains $pboPayload 'PHEN_CS_CSS_FocusStatusKey' 'Packed PBO must not contain the removed Argus focus status keybind.'
Assert-NotContains $pboPayload 'PHEN_CS_fnc_CSS_showFocusStatus' 'Packed PBO must not contain the removed Argus focus status function.'
Assert-NotContains $pboPayload 'PHEN_CS_ArgusIntegratedBinocular' 'Packed PBO must not contain the removed Argus binocular weapon.'
Assert-NotContains $pboPayload 'class ArgusStepZoom' 'Packed PBO must not contain the removed Argus stepped zoom optics mode.'
Assert-NotContains $pboPayload 'camCreate' 'Packed PBO must not contain scripted camera zoom logic.'
Assert-NotContains $pboPayload 'camSetFov' 'Packed PBO must not contain scripted camera FOV zoom logic.'

if ($errors.Count -gt 0) {
    Write-Host 'Argus ocular implant verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'Argus ocular implant verification passed.'
