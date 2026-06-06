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

$settingsPath = Join-Path $sourceRoot 'bootstrap\Settings_PreInit.sqf'
$preInitPath = Join-Path $sourceRoot 'bootstrap\XEH_PreInit.sqf'

$settings = Get-Content -LiteralPath $settingsPath -Raw
$preInit = Get-Content -LiteralPath $preInitPath -Raw
$combined = $settings + "`n" + $preInit
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

function Assert-NotRegex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $script:errors.Add($Message)
    }
}

Assert-Contains $settings '#define PHEN_CS_KEYBIND_CAT_HUD "[FOD] Cybernetics System - HUD"' 'HUD keybind category is not a stable registry string.'
Assert-Contains $preInit '#define PHEN_CS_KEYBIND_CAT_MOVEMENT "[FOD] Cybernetics System - Movement"' 'Movement keybind category is not a stable registry string.'
Assert-Contains $preInit '#define PHEN_CS_KEYBIND_CAT_TACHUD "[FOD] Cybernetics System - Tactical HUD"' 'TacHUD keybind category is not a stable registry string.'

Assert-Contains $settings '[PHEN_CS_KEYBIND_CAT_HUD, "CheckCyberneticsOther"' 'CheckCyberneticsOther does not use the stable HUD keybind category.'
Assert-Contains $settings '[PHEN_CS_KEYBIND_CAT_HUD, "CheckCyberneticsSelf"' 'CheckCyberneticsSelf does not use the stable HUD keybind category.'
Assert-Contains $preInit 'PHEN_CS_KEYBIND_CAT_MOVEMENT,                       // Stable CBA keybind registry category' 'PHEN_CS_JumpKey does not use the stable Movement keybind category.'
Assert-Contains $preInit 'PHEN_CS_KEYBIND_CAT_MOVEMENT,' 'PHEN_CS_Dash_Key does not use the stable Movement keybind category.'
Assert-Contains $preInit 'PHEN_CS_KEYBIND_CAT_TACHUD,' 'PHEN_CS_TacHUD_ToggleKey does not use the stable TacHUD keybind category.'

Assert-NotRegex $combined '\[\s*PHEN_CS_L\("STR_PHEN_CS_CBA_CAT_[^"]+"\)[\s\S]{0,300}?\]\s*call\s+[Cc][Bb][Aa]_fnc_addKeybind' 'A CBA keybind still uses a localized category as the registry key.'

if ($errors.Count -gt 0) {
    Write-Host 'CBA keybind registry verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'CBA keybind registry verification passed.'
