$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Source = Join-Path $RepoRoot 'packaging/mod'
$Target = Join-Path $RepoRoot 'out/mods/return-to-tristram'

if (Test-Path $Target) {
    Remove-Item $Target -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item (Join-Path $Source '*') $Target -Recurse -Force

Write-Host "Staged Return to Tristram mod at: $Target"
Write-Host 'No Blizzard assets or unreviewed third-party mod code are included.'
