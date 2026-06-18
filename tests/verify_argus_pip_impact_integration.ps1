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
$postInitPath = Join-Path $sourceRoot 'bootstrap\XEH_postInit.sqf'
$pboPath = Join-Path $Root 'addons\PHEN_Cybernetics.pbo'
$postInit = Get-Content -LiteralPath $postInitPath -Raw
$pboPayload = if (Test-Path -LiteralPath $pboPath) {
    [System.Text.Encoding]::GetEncoding(28591).GetString([System.IO.File]::ReadAllBytes($pboPath))
} else {
    ''
}
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

function Assert-Regex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    $options = [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    $timeout = [TimeSpan]::FromSeconds(3)
    try {
        $matched = [regex]::new($Pattern, $options, $timeout).IsMatch($Text)
    } catch [System.Text.RegularExpressions.RegexMatchTimeoutException] {
        $script:errors.Add("Regex timed out while checking: $Message")
        return
    }

    if (-not $matched) {
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

function Assert-NotRegex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    $options = [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    $timeout = [TimeSpan]::FromSeconds(3)
    try {
        $matched = [regex]::new($Pattern, $options, $timeout).IsMatch($Text)
    } catch [System.Text.RegularExpressions.RegexMatchTimeoutException] {
        $script:errors.Add("Regex timed out while checking: $Message")
        return
    }

    if ($matched) {
        $script:errors.Add($Message)
    }
}

function Get-TextBetween {
    param(
        [string]$Text,
        [string]$StartNeedle,
        [string]$EndNeedle
    )

    $start = $Text.IndexOf($StartNeedle, [System.StringComparison]::Ordinal)
    if ($start -lt 0) { return '' }
    $end = $Text.IndexOf($EndNeedle, $start + $StartNeedle.Length, [System.StringComparison]::Ordinal)
    if ($end -lt 0 -or $end -le $start) { return $Text.Substring($start) }
    return $Text.Substring($start, $end - $start)
}

$updateAimPredictionRuntime = Get-TextBetween $postInit 'PHEN_CS_fnc_CSS_updateAimPrediction = {' 'PHEN_CS_fnc_CSS_getAimDrawASL = {'

$removedBallisticSymbols = @(
    'PHEN_CS_fnc_CSS_traceBallisticProfile',
    'PHEN_CS_fnc_CSS_stepProjectileVelocity',
    'PHEN_CS_fnc_CSS_solveZeroedAimFrame',
    'PHEN_CS_fnc_CSS_traceAimTrajectory',
    'PHEN_CS_fnc_CSS_traceLaunchFramePrediction',
    'PHEN_CS_fnc_CSS_getBallisticData',
    'PHEN_CS_fnc_CSS_getAimFrame',
    'PHEN_CS_fnc_CSS_getAimCacheKey',
    'PHEN_CS_fnc_CSS_getReusableAimSolution',
    'PHEN_CS_fnc_CSS_storeAimSolutionCache',
    'PHEN_CS_fnc_CSS_getShotCalibration',
    'PHEN_CS_fnc_CSS_storeShotCalibration',
    'PHEN_CS_fnc_CSS_applyAimCalibration',
    'PHEN_CS_fnc_CSS_applySpeedCalibration',
    'PHEN_CS_fnc_CSS_getProjectileFamily',
    'PHEN_CS_fnc_CSS_getRocketAccel',
    'PHEN_CS_fnc_CSS_logAimCorrectionDebug',
    'PHEN_CS_CSS_ShotCalibration',
    'PHEN_CS_CSS_AimCache',
    'PHEN_CS_CSS_BallisticConfigCache',
    'PHEN_CS_CSS_CalibrationMinBias',
    'PHEN_CS_CSS_UseShotCalibration',
    '[PHEN_CS][ArgusAimCorrection]',
    'rocket_approx',
    'preShotUncorrectedAimPointASL',
    'preShotCorrectedAimPointASL',
    'impactVsCorrectedError',
    'impactVsCorrectedVectorASL',
    'calibrationSharedAcrossZeroing'
)

foreach ($removedSymbol in $removedBallisticSymbols) {
    Assert-NotContains $postInit $removedSymbol "Removed CSS ballistic/calibration/cache symbol is still present in source runtime: $removedSymbol"
    Assert-NotContains $pboPayload $removedSymbol "Removed CSS ballistic/calibration/cache symbol is still present in packed PBO: $removedSymbol"
}

Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getPIPWindVector' 'Missing PIP wind-vector helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_getPIPWindVector' 'Packed PBO is missing the PIP wind-vector helper.'
Assert-Contains $postInit 'ace_winddeflection_fnc_getCurrentWind' 'PIP wind helper must prefer ACE wind deflection.'
Assert-Contains $postInit 'ace_weather_fnc_calculateWindSpeed' 'PIP wind helper must fall back to ACE weather wind speed.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyPIPScopeAdjustment' 'Missing PIP scope-adjustment helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_applyPIPScopeAdjustment' 'Packed PBO is missing the PIP scope-adjustment helper.'
Assert-Contains $postInit '0.05729577951308232' 'ACE scope mil adjustments must be converted to degrees.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getPIPImpactSolution' 'Argus must use a PIP-only impact solution entrypoint.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_getPIPImpactSolution' 'Packed PBO is missing the PIP-only impact solution entrypoint.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getPIPImpactSolution\s*=\s*\{[\s\S]*PIP_fnc_accelACE[\s\S]*PIP_fnc_firstValidHit' 'PIP-only entrypoint must contain the copied EBW bullet/ACE calculation primitives.'
Assert-Contains $postInit 'PHEN_CS_CSS_PIPUpdateMinInterval' 'PIP integration must throttle repeated impact calculations instead of running EBW pathfinding every Aim PFH tick.'
Assert-Contains $postInit 'PHEN_CS_CSS_PIPNoSolutionRetryInterval' 'PIP integration must back off repeated no-solution attempts to avoid FPS drops.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getPIPImpactSolution\s*=\s*\{[\s\S]*PHEN_CS_CSS_PIPNextUpdateAt[\s\S]*PHEN_CS_CSS_PIPLastSolution[\s\S]*then\s*\{\s*\+PHEN_CS_CSS_PIPLastSolution\s*\}' 'PIP-only entrypoint must reuse the last valid PIP result during the throttle window.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getPIPImpactSolution\s*=\s*\{[\s\S]*PHEN_CS_CSS_PIPNoSolutionRetryInterval[\s\S]*pip_ebw_no_solution' 'PIP-only entrypoint must use no-solution backoff when EBW cannot produce a valid hit.'
Assert-Regex $postInit 'if\s*\(PIP_useACE_AB && \{ PIP_paramsACE isEqualTo \[\] \}\)\s*then\s*\{ PIP_useACE_AB = false; \};' 'PIP integration must fall back to EBW mode when ACE advanced ballistics is enabled but no ACE PIP parameters are available for the ammo.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'Missing PIP 40mm GL trajectory helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'Packed PBO is missing the PIP 40mm GL trajectory helper.'
Assert-Contains $postInit '1Rnd_HE_Grenade_shell' 'PIP 40mm helper must include the single HE grenade magazine.'
Assert-Contains $pboPayload '1Rnd_HE_Grenade_shell' 'Packed PBO is missing the single HE grenade magazine route.'
Assert-Contains $postInit '3Rnd_HE_Grenade_shell' 'PIP 40mm helper must include the 3-round HE grenade magazine.'
Assert-Contains $pboPayload '3Rnd_HE_Grenade_shell' 'Packed PBO is missing the 3-round HE grenade magazine route.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_getPIPImpactSolution\s*=\s*\{[\s\S]*PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'PIP-only entrypoint must route supported shell predictions through the 40mm PIP helper.'
Assert-Regex $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_updateAimPrediction\s*=\s*\{[\s\S]*PHEN_CS_fnc_CSS_getPIPImpactSolution' 'Argus aim prediction must call the PIP-only impact solution entrypoint.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_getReusableAimSolution' 'Argus aim prediction must not use the old aim cache.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_storeAimSolutionCache' 'Argus aim prediction must not store old cached aim solutions.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_getShotCalibration' 'Argus aim prediction must not read old shot calibration.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_storeShotCalibration' 'Argus aim prediction must not write old shot calibration.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_applyAimCalibration' 'Argus aim prediction must not apply old aim calibration.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_traceBallisticProfile' 'Argus aim prediction must not call the old CSS ballistic tracer.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_stepProjectileVelocity' 'Argus aim prediction must not call the old CSS velocity stepper.'
Assert-NotContains $updateAimPredictionRuntime 'PHEN_CS_fnc_CSS_solveZeroedAimFrame' 'Argus aim prediction must not call the old CSS zeroing solver.'
Assert-NotRegex $updateAimPredictionRuntime 'PHEN_CS_CSS_AimSolution\s*=\s*\[_aimCacheKey' 'Argus aim prediction must write direct PIP solutions, not cache-key-wrapped CSS solutions.'
Assert-NotRegex $postInit 'call\s+PHEN_CS_fnc_CSS_storeShotCalibration' 'Argus must not feed the old fired-projectile calibration loop.'

if ($errors.Count -gt 0) {
    Write-Host 'Argus PIP impact integration verification failed:'
    foreach ($err in $errors) {
        Write-Host " - $err"
    }
    exit 1
}

Write-Host 'Argus PIP impact integration verification passed.'
