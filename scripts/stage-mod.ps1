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

python (Join-Path $PSScriptRoot 'generate-framework-data.py') --output $Target
if ($LASTEXITCODE -ne 0) {
    throw 'RTT framework data generation failed.'
}

$DiscoveryEntry = Join-Path $Target 'lua/mods/return-to-tristram/init.lua'
if (-not (Test-Path $DiscoveryEntry)) {
    throw 'RTT staging is missing the DevilutionX loose-mod discovery entry point.'
}
foreach ($GeneratedRuntimeFile in @(
    'lua/mods/rtt/generated/content_ids.lua',
    'lua/mods/rtt/generated/contract.lua'
)) {
    if (-not (Test-Path (Join-Path $Target $GeneratedRuntimeFile))) {
        throw "RTT staging is missing generated framework runtime file: $GeneratedRuntimeFile"
    }
}

Write-Host "Staged Return to Tristram mod at: $Target"
