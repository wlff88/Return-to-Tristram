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

python (Join-Path $PSScriptRoot 'export-mod-data.py') --output $Target
if ($LASTEXITCODE -ne 0) {
    throw 'RTT data export failed.'
}

Write-Host "Staged Return to Tristram mod at: $Target"
