param(
    [string]$EvidenceDir = "out/runtime-acceptance/evidence"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $RepoRoot

function Read-Pass([string]$Question) {
    while ($true) {
        $answer = (Read-Host "$Question [y/n]").Trim().ToLowerInvariant()
        if ($answer -in @("y", "yes")) { return $true }
        if ($answer -in @("n", "no")) { return $false }
        Write-Host "Please answer y or n."
    }
}

$ResolvedEvidenceDir = Join-Path $RepoRoot $EvidenceDir
New-Item -ItemType Directory -Force -Path $ResolvedEvidenceDir | Out-Null

$Result = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    rttCommit = (git rev-parse HEAD).Trim()
    phase = "Phase 3 Classic+"
    modLaunch = Read-Pass "Did RTT launch without missing-asset errors with the mod active?"
    visualStore = Read-Pass "Was the visual-grid vendor store the default and usable with mouse/controller?"
    lootFilter2 = Read-Pass "Did Loot Filter 2.0 balanced mode behave correctly without hiding protected item classes?"
    itemComparison = Read-Pass "Did identified equipment show the RTT equipped-item comparison block?"
    monsterResistances = Read-Pass "Were exact monster resistance/immunity categories visible immediately?"
    weaponSwapKeyboard = Read-Pass "Did W swap one-hand+shield and two-hand weapon sets correctly?"
    weaponSwapController = Read-Pass "Did Back/Select + Y swap weapon sets on the controller?"
    weaponSwapSaveReload = Read-Pass "Did both weapon sets and active-set state survive save/quit/reload?"
    stashTransfer = Read-Pass "Did Ctrl-click inventory/stash transfer work correctly?"
    autoGoldAndBelt = Read-Pass "Did auto-gold and belt refill behave correctly?"
    controllerFlow = Read-Pass "Did controller navigation work through menu, movement, combat, inventory, stash and vendor UI?"
    multiplayerWeaponSync = Read-Pass "Did a second RTT client see active weapon swaps without crash/desync?"
    campaignRegression = Read-Pass "Did the original campaign regression path through Diablo complete without Classic+ blockers?"
    passed = $false
}

$RequiredKeys = @(
    "modLaunch",
    "visualStore",
    "lootFilter2",
    "itemComparison",
    "monsterResistances",
    "weaponSwapKeyboard",
    "weaponSwapController",
    "weaponSwapSaveReload",
    "stashTransfer",
    "autoGoldAndBelt",
    "controllerFlow",
    "multiplayerWeaponSync",
    "campaignRegression"
)

$Passed = $true
foreach ($Key in $RequiredKeys) {
    if (-not $Result[$Key]) {
        $Passed = $false
        break
    }
}
$Result.passed = $Passed

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$EvidencePath = Join-Path $ResolvedEvidenceDir "phase3-$Timestamp.json"
$Result | ConvertTo-Json -Depth 4 | Set-Content -Path $EvidencePath -Encoding UTF8

if ($Result.passed) {
    Write-Host "PASS: Phase 3 Classic+ runtime acceptance confirmed." -ForegroundColor Green
    Write-Host "Evidence: $EvidencePath"
    exit 0
}

Write-Host "INCOMPLETE/FAIL: at least one Phase 3 runtime gate was not confirmed." -ForegroundColor Yellow
Write-Host "Evidence: $EvidencePath"
exit 2
