param(
    [Parameter(Mandatory = $true)]
    [string]$DiabloDataPath,

    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$Configuration = "Release",

    [switch]$SkipBuild,
    [switch]$SkipStage,
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $RepoRoot

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Require-Path([string]$Path, [string]$Description) {
    if (-not (Test-Path $Path)) {
        throw "$Description not found: $Path"
    }
}

function Read-Pass([string]$Question) {
    while ($true) {
        $answer = (Read-Host "$Question [y/n]").Trim().ToLowerInvariant()
        if ($answer -in @("y", "yes")) { return $true }
        if ($answer -in @("n", "no")) { return $false }
        Write-Host "Please answer y or n."
    }
}

function New-LaunchArguments([string]$DataPath, [string]$SavesPath, [string]$ConfigPath) {
    return "--data-dir `"$DataPath`" --save-dir `"$SavesPath`" --config-dir `"$ConfigPath`" --diablo -n"
}

$DataDir = (Resolve-Path $DiabloDataPath).Path
$DiabdatCandidates = @(
    (Join-Path $DataDir "DIABDAT.MPQ"),
    (Join-Path $DataDir "diabdat.mpq")
)
$Diabdat = $DiabdatCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($null -eq $Diabdat) {
    throw "No DIABDAT.MPQ/diabdat.mpq found in $DataDir. Supply a directory containing legally obtained Diablo game data."
}

Write-Step "Verify pinned engine baseline"
python scripts/verify-baseline.py
if ($LASTEXITCODE -ne 0) { throw "Pinned DevilutionX baseline verification failed." }

if (-not $SkipBuild) {
    Write-Step "Bootstrap pinned DevilutionX"
    & "$PSScriptRoot/bootstrap-devilutionx.ps1"
    if ($LASTEXITCODE -ne 0) { throw "DevilutionX bootstrap failed." }

    Write-Step "Build RTT-patched DevilutionX ($Configuration)"
    & "$PSScriptRoot/build-windows.ps1" -Configuration $Configuration
    if ($LASTEXITCODE -ne 0) { throw "Windows build failed." }
}

if (-not $SkipStage) {
    Write-Step "Stage Return to Tristram runtime mod"
    & "$PSScriptRoot/stage-mod.ps1"
    if ($LASTEXITCODE -ne 0) { throw "RTT mod staging failed." }
}

$ExeCandidates = @(
    (Join-Path $RepoRoot "build/devilutionx-windows-x64/$Configuration/devilutionx.exe"),
    (Join-Path $RepoRoot "build/devilutionx-windows-x64/devilutionx.exe")
)
$ExePath = $ExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($null -eq $ExePath) {
    throw "devilutionx.exe was not found in the expected Windows build output."
}
$ExePath = (Resolve-Path $ExePath).Path
$ExeDir = Split-Path $ExePath -Parent

$StagedMod = Join-Path $RepoRoot "out/mods/return-to-tristram"
Require-Path $StagedMod "Staged RTT mod"
Require-Path (Join-Path $StagedMod "manifest.ini") "RTT manifest"
Require-Path (Join-Path $StagedMod "lua/mods/rtt/init.lua") "RTT Lua bootstrap"

$RuntimeRoot = Join-Path $RepoRoot "out/runtime-acceptance"
$ConfigDir = Join-Path $RuntimeRoot "config"
$SaveDir = Join-Path $RuntimeRoot "saves"
$EvidenceDir = Join-Path $RuntimeRoot "evidence"
$RuntimeMod = Join-Path $ExeDir "mods/return-to-tristram"

New-Item -ItemType Directory -Force -Path $ConfigDir, $SaveDir, $EvidenceDir, (Split-Path $RuntimeMod -Parent) | Out-Null
if (Test-Path $RuntimeMod) {
    Remove-Item -Recurse -Force $RuntimeMod
}
Copy-Item -Recurse -Force $StagedMod $RuntimeMod

# DevilutionX discovers loose mods at mods/<name>/manifest.ini. The mod option key
# is the loose-mod directory name; use an isolated config so acceptance does not
# alter the user's normal DevilutionX settings.
$IniPath = Join-Path $ConfigDir "diablo.ini"
@"
[Mods]
return-to-tristram=true
"@ | Set-Content -Path $IniPath -Encoding UTF8

Write-Step "CLI preflight"
$VersionOutput = & $ExePath --version 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) { throw "devilutionx.exe --version failed." }
Write-Host $VersionOutput.Trim()

$Commit = (git rev-parse HEAD).Trim()
$EngineCommit = (git -C Engine/devilutionx rev-parse HEAD).Trim()
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$EvidencePath = Join-Path $EvidenceDir "phase1-$Timestamp.json"

$Result = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    rttCommit = $Commit
    engineCommit = $EngineCommit
    configuration = $Configuration
    executablePreflight = $true
    diabdatPresent = $true
    modStaged = $true
    modConfiguredEnabled = $true
    firstSessionExitCode = $null
    rttSaveDetected = $false
    modVisibleAndLoaded = $false
    reachedTristram = $false
    reachedCathedralLevel1 = $false
    combatAndRttHooks = $false
    saveReload = $false
    controllerFlow = $false
    multiplayerBaseline = $false
    passed = $false
}

if ($NoLaunch) {
    Write-Step "Preflight complete (NoLaunch)"
    $Result | ConvertTo-Json -Depth 4 | Set-Content -Path $EvidencePath -Encoding UTF8
    Write-Host "Evidence: $EvidencePath"
    exit 0
}

$LaunchArgs = New-LaunchArguments -DataPath $DataDir -SavesPath $SaveDir -ConfigPath $ConfigDir

Write-Step "Acceptance session 1"
Write-Host "In this session: confirm RTT is enabled, create a character, reach Tristram, enter Cathedral Level 1, kill at least one monster, verify loot-filter/resistance UI behavior, save, then exit DevilutionX."
$Process = Start-Process -FilePath $ExePath -ArgumentList $LaunchArgs -WorkingDirectory $ExeDir -PassThru -Wait
$Result.firstSessionExitCode = $Process.ExitCode

$RttSaves = Get-ChildItem -Path $SaveDir -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Extension -ieq ".rtt" -or $_.Name -match "_rtt($|\.)"
}
$Result.rttSaveDetected = @($RttSaves).Count -gt 0

$Result.modVisibleAndLoaded = Read-Pass "Was Return to Tristram visible/enabled in the mod settings and loaded for the game?"
$Result.reachedTristram = Read-Pass "Did the new game reach Tristram normally?"
$Result.reachedCathedralLevel1 = Read-Pass "Did you enter Cathedral Level 1?"
$Result.combatAndRttHooks = Read-Pass "Did combat work and did the RTT loot-filter/resistance-display hooks behave correctly?"

Write-Step "Acceptance session 2: save reload + controller"
Write-Host "Reload the RTT character/save. Exercise menu navigation, movement, combat and inventory with an Xbox-class controller, then exit."
$ReloadProcess = Start-Process -FilePath $ExePath -ArgumentList $LaunchArgs -WorkingDirectory $ExeDir -PassThru -Wait
$Result.saveReload = Read-Pass "Did the RTT save reload successfully?"
$Result.controllerFlow = Read-Pass "Did controller navigation work from menus through movement/combat/inventory?"

Write-Step "Multiplayer baseline"
if (Read-Pass "Run the two-client multiplayer baseline now?") {
    $Client2Config = Join-Path $RuntimeRoot "config-client2"
    $Client2Save = Join-Path $RuntimeRoot "saves-client2"
    New-Item -ItemType Directory -Force -Path $Client2Config, $Client2Save | Out-Null
    Copy-Item -Force $IniPath (Join-Path $Client2Config "diablo.ini")

    $Client2Args = New-LaunchArguments -DataPath $DataDir -SavesPath $Client2Save -ConfigPath $Client2Config

    $Client1 = Start-Process -FilePath $ExePath -ArgumentList $LaunchArgs -WorkingDirectory $ExeDir -PassThru
    $Client2 = Start-Process -FilePath $ExePath -ArgumentList $Client2Args -WorkingDirectory $ExeDir -PassThru
    Write-Host "Connect the two clients to the same multiplayer game, move both characters, perform basic combat, then close both clients."
    $Client1.WaitForExit()
    $Client2.WaitForExit()
    $Result.multiplayerBaseline = Read-Pass "Did both clients connect and complete basic movement/combat without an obvious desync or crash?"
} else {
    $Result.multiplayerBaseline = $false
}

$Result.passed = (
    $Result.executablePreflight -and
    $Result.diabdatPresent -and
    $Result.modStaged -and
    $Result.modConfiguredEnabled -and
    ($Result.firstSessionExitCode -eq 0) -and
    $Result.rttSaveDetected -and
    $Result.modVisibleAndLoaded -and
    $Result.reachedTristram -and
    $Result.reachedCathedralLevel1 -and
    $Result.combatAndRttHooks -and
    $Result.saveReload -and
    $Result.controllerFlow -and
    $Result.multiplayerBaseline
)

$Result | ConvertTo-Json -Depth 4 | Set-Content -Path $EvidencePath -Encoding UTF8

Write-Step "Phase 1 acceptance result"
if ($Result.passed) {
    Write-Host "PASS: all Phase 1 runtime acceptance gates were confirmed." -ForegroundColor Green
    Write-Host "Evidence: $EvidencePath"
    exit 0
}

Write-Host "INCOMPLETE/FAIL: at least one Phase 1 runtime gate was not confirmed." -ForegroundColor Yellow
Write-Host "Evidence: $EvidencePath"
exit 2
