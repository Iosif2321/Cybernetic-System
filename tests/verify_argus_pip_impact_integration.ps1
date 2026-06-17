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

$aimCacheKeyRuntime = Get-TextBetween $postInit 'PHEN_CS_fnc_CSS_getAimCacheKey' 'PHEN_CS_fnc_CSS_refreshAimSolutionExpiry'

Assert-Contains $postInit 'PHEN_CS_fnc_CSS_getPIPWindVector' 'Missing PIP wind-vector helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_getPIPWindVector' 'Packed PBO is missing the PIP wind-vector helper.'
Assert-Contains $postInit 'ace_winddeflection_fnc_getCurrentWind' 'PIP wind helper must prefer ACE wind deflection.'
Assert-Contains $postInit 'ace_weather_fnc_calculateWindSpeed' 'PIP wind helper must fall back to ACE weather wind speed.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_applyPIPScopeAdjustment' 'Missing PIP scope-adjustment helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_applyPIPScopeAdjustment' 'Packed PBO is missing the PIP scope-adjustment helper.'
Assert-Contains $postInit '0.05729577951308232' 'ACE scope mil adjustments must be converted to degrees.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_stepProjectileVelocity\s*=\s*\{[\s\S]*_posASL[\s\S]*PHEN_CS_fnc_CSS_getPIPWindVector[\s\S]*PHEN_CS_fnc_CSS_getACEBallisticDragAccel' 'Bullet ACE drag must use PIP wind-relative velocity.'
Assert-Contains $postInit 'PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'Missing PIP 40mm GL trajectory helper.'
Assert-Contains $pboPayload 'PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'Packed PBO is missing the PIP 40mm GL trajectory helper.'
Assert-Contains $postInit '1Rnd_HE_Grenade_shell' 'PIP 40mm helper must include the single HE grenade magazine.'
Assert-Contains $pboPayload '1Rnd_HE_Grenade_shell' 'Packed PBO is missing the single HE grenade magazine route.'
Assert-Contains $postInit '3Rnd_HE_Grenade_shell' 'PIP 40mm helper must include the 3-round HE grenade magazine.'
Assert-Contains $pboPayload '3Rnd_HE_Grenade_shell' 'Packed PBO is missing the 3-round HE grenade magazine route.'
Assert-Regex $postInit 'PHEN_CS_fnc_CSS_traceBallisticProfile\s*=\s*\{[\s\S]*PHEN_CS_fnc_CSS_tracePIP40mmGLProfile' 'Main tracer must route supported shell predictions through the PIP 40mm helper.'
Assert-Contains $aimCacheKeyRuntime '_scopeAdjustmentTelemetry' 'Aim cache key must include ACE scope state.'
Assert-Contains $aimCacheKeyRuntime '_windTelemetry' 'Aim cache key must include wind state.'

if ($errors.Count -gt 0) {
    Write-Host 'Argus PIP impact integration verification failed:'
    foreach ($err in $errors) {
        Write-Host " - $err"
    }
    exit 1
}

Write-Host 'Argus PIP impact integration verification passed.'
