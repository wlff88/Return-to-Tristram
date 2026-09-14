param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnginePath = Join-Path $RepoRoot 'Engine/devilutionx'
$ExpectedSha = 'ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6'

Push-Location $RepoRoot
try {
    git submodule sync --recursive
    git submodule update --init --recursive

    $ActualSha = (git -C $EnginePath rev-parse HEAD).Trim()
    if ($ActualSha -ne $ExpectedSha) {
        if (-not $Force) {
            throw "DevilutionX baseline mismatch. Expected $ExpectedSha, got $ActualSha. Re-run with -Force only if you intentionally updated the baseline."
        }
        Write-Warning "Baseline mismatch accepted because -Force was provided."
    }

    Write-Host "DevilutionX baseline ready: $ActualSha"
    Write-Host 'Next: scripts/build-windows.ps1'
}
finally {
    Pop-Location
}
