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

$preInitPath = Join-Path $sourceRoot 'bootstrap\XEH_PreInit.sqf'
$modulePath = Join-Path $sourceRoot 'functions\fn_AddTerminalActions.sqf'

$preInit = Get-Content -LiteralPath $preInitPath -Raw
$module = Get-Content -LiteralPath $modulePath -Raw
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

function Assert-RegexCountAtLeast {
    param(
        [string]$Text,
        [string]$Pattern,
        [int]$Minimum,
        [string]$Message
    )

    $count = ([regex]::Matches($Text, $Pattern)).Count
    if ($count -lt $Minimum) {
        $script:errors.Add("$Message Found $count, expected at least $Minimum.")
    }
}

function Assert-NotRegex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ([regex]::IsMatch($Text, $Pattern)) {
        $script:errors.Add($Message)
    }
}

Assert-Contains $preInit 'PHEN_CS_fnc_normalizeRipperdocAccessList' 'Missing helper that normalizes module/object Ripperdoc access lists.'
Assert-Contains $preInit 'PHEN_CS_fnc_isRipperdocImplantAllowed' 'Missing helper that checks whitelist/blacklist membership.'
Assert-Contains $preInit 'PHEN_CS_fnc_GetRipperdocCyberneticMasterList' 'Missing helper that returns a ZEN COMBO-compatible filtered Ripperdoc list.'
Assert-Contains $preInit '_object setVariable ["PHEN_CS_RipperdocAllowedList", _allowedList, false];' 'Client-side Ripperdoc actions do not receive PHEN_CS_RipperdocAllowedList.'
Assert-Contains $preInit '_object setVariable ["PHEN_CS_RipperdocDeniedList", _deniedList, false];' 'Client-side Ripperdoc actions do not receive PHEN_CS_RipperdocDeniedList.'
Assert-RegexCountAtLeast $preInit 'call\s+PHEN_CS_fnc_GetRipperdocCyberneticMasterList' 3 'Ripperdoc install dialogs are not all using the filtered list.'
Assert-NotRegex $preInit '\["COMBO",\s*\["Cybernetics",\s*"Select the Cybernetics to implant (?:into yourself|into the patient)"\],\s*PHEN_CS_Cybernetic_MasterList\]' 'A Ripperdoc install dialog still exposes the full master list directly.'

Assert-Contains $module 'PHEN_CS_RipperdocAccessMode' 'Module init wrapper does not read PHEN_CS_RipperdocAccessMode.'
Assert-Contains $module 'PHEN_CS_RipperdocAccessList' 'Module init wrapper does not read PHEN_CS_RipperdocAccessList.'
Assert-Contains $module 'PHEN_CS_RipperdocDeniedList' 'Module init wrapper does not read the alias PHEN_CS_RipperdocDeniedList.'
Assert-RegexCountAtLeast $module 'call\s+PHEN_CS_fnc_AddTerminalActions' 1 'Module init wrapper no longer calls PHEN_CS_fnc_AddTerminalActions.'

if ($errors.Count -gt 0) {
    Write-Host 'Ripperdoc module filter verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'Ripperdoc module filter verification passed.'
