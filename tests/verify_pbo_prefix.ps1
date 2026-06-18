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
$prefixPath = Join-Path $sourceRoot '$PBOPREFIX$'
$pboPath = Join-Path $Root 'addons\PHEN_Cybernetics.pbo'
$bankRevPath = 'C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\BankRev\BankRev.exe'
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

if (-not (Test-Path -LiteralPath $prefixPath)) {
    $errors.Add('Source addon is missing $PBOPREFIX$. FileBank then writes a temporary build-folder prefix that breaks Arma virtual script paths.')
} else {
    $prefix = (Get-Content -LiteralPath $prefixPath -Raw).Trim()
    if (-not ($prefix -eq 'PHEN_Cybernetics')) {
        $errors.Add("Source `$PBOPREFIX$ must be PHEN_Cybernetics, found '$prefix'.")
    }
}

if (-not (Test-Path -LiteralPath $pboPath)) {
    $errors.Add('Packed PBO addons\PHEN_Cybernetics.pbo is missing.')
} elseif (-not (Test-Path -LiteralPath $bankRevPath)) {
    $errors.Add('BankRev.exe is required to verify the packed PBO prefix, but it was not found.')
} else {
    $properties = (& $bankRevPath -p $pboPath 2>&1) -join "`n"
    $fullList = (& $bankRevPath -lf $pboPath 2>&1) -join "`n"

    Assert-Contains $properties 'prefix = PHEN_Cybernetics\' 'Packed PBO prefix must be PHEN_Cybernetics\.'
    Assert-NotContains $properties '_pbo_build' 'Packed PBO prefix must not point at the temporary _pbo_build folder.'
    Assert-Contains $fullList 'PHEN_Cybernetics\functions\fn_addterminalactions.sqf' 'Packed PBO must expose fn_AddTerminalActions.sqf under the PHEN_Cybernetics virtual path.'
    Assert-NotContains $fullList '_pbo_build' 'Packed PBO file list must not expose temporary _pbo_build paths.'
}

if ($errors.Count -gt 0) {
    Write-Host 'PBO prefix verification failed:'
    foreach ($errorItem in $errors) {
        Write-Host " - $errorItem"
    }
    exit 1
}

Write-Host 'PBO prefix verification passed.'
