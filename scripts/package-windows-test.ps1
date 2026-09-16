param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BuildDir = Join-Path $RepoRoot 'build/devilutionx-windows-x64'
$EngineDir = Join-Path $RepoRoot 'Engine/devilutionx'
$EngineAssetsDir = Join-Path $EngineDir 'assets'
$OutRoot = Join-Path $RepoRoot 'out/windows-test-build'
$Version = (Get-Content (Join-Path $RepoRoot 'VERSION') -Raw).Trim()
$RttCommit = (git -C $RepoRoot rev-parse HEAD).Trim()
$EngineCommit = (git -C $EngineDir rev-parse HEAD).Trim()
$ShortCommit = $RttCommit.Substring(0, 8)
$PackageName = "Return-to-Tristram-$Version-Windows-x64-test-$ShortCommit"
$PackageDir = Join-Path $OutRoot $PackageName
$ZipPath = Join-Path $OutRoot "$PackageName.zip"

$ExeCandidates = @(
    (Join-Path $BuildDir "$Configuration/devilutionx.exe"),
    (Join-Path $BuildDir 'devilutionx.exe')
)
$ExePath = $ExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($null -eq $ExePath) {
    throw "devilutionx.exe not found under $BuildDir. Build Windows x64 first."
}
$ExePath = (Resolve-Path $ExePath).Path
$RuntimeSourceDir = Split-Path $ExePath -Parent

if (-not (Test-Path (Join-Path $EngineAssetsDir 'lua/inspect.lua'))) {
    throw 'Pinned DevilutionX source is missing assets/lua/inspect.lua.'
}

Write-Host "Packaging runtime from: $RuntimeSourceDir"
Write-Host "Pinned engine assets from: $EngineAssetsDir"

if (Test-Path $PackageDir) {
    Remove-Item -Recurse -Force $PackageDir
}
if (Test-Path $ZipPath) {
    Remove-Item -Force $ZipPath
}
New-Item -ItemType Directory -Force -Path $PackageDir, $OutRoot | Out-Null

# vcpkg's app-local deployment step puts the executable and its runtime DLLs
# together in the same flat directory for both generators. For the Visual
# Studio generator that directory is the per-config Release/ subfolder, which
# happens to contain nothing else. For Ninja (single-config) it is the build
# root itself, which also holds vcpkg_installed/, CMakeFiles/ and similar
# build-tree clutter -- recursing into vcpkg_installed's intermediate build
# trees can even fail outright on files with unusual permissions there. Copy
# only the top-level files (the exe plus its DLLs) instead of the whole tree.
Get-ChildItem -Path $RuntimeSourceDir -File | Copy-Item -Destination $PackageDir -Force

if (-not (Test-Path (Join-Path $PackageDir 'devilutionx.exe'))) {
    throw 'Packaged runtime is missing devilutionx.exe.'
}

# IMPORTANT: keep engine binary and engine assets on the same pinned revision.
$LooseAssetsDir = Join-Path $PackageDir 'assets'
New-Item -ItemType Directory -Force -Path $LooseAssetsDir | Out-Null
Copy-Item (Join-Path $EngineAssetsDir '*') $LooseAssetsDir -Recurse -Force

$RequiredPinnedAssets = @(
    'lua/inspect.lua',
    'lua/devilutionx/events.lua',
    'lua_internal/get_lua_function_signature.lua',
    'ASSETS_VERSION'
)
foreach ($relative in $RequiredPinnedAssets) {
    $path = Join-Path $LooseAssetsDir $relative
    if (-not (Test-Path $path)) {
        throw "Pinned runtime asset missing from package: assets/$relative"
    }
}

$AssetsPath = Join-Path $PackageDir 'devilutionx.mpq'
$ExistingAssets = Get-ChildItem -Path $BuildDir -Filter 'devilutionx.mpq' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -ne $ExistingAssets) {
    Copy-Item $ExistingAssets.FullName $AssetsPath -Force
    $AssetsMode = "pinned-loose-assets + build-generated devilutionx.mpq:$($ExistingAssets.FullName)"
} else {
    $AssetsMode = 'pinned-loose-assets (no external devilutionx.mpq fallback)'
}

$ConfigDir = Join-Path $PackageDir 'config'
$SaveDir = Join-Path $PackageDir 'saves'
New-Item -ItemType Directory -Force -Path $ConfigDir, $SaveDir | Out-Null

# --save-dir sets DevilutionX PrefPath. Loose mods are discovered under
# <PrefPath>/mods/<name>, so the active RTT runtime MUST live below .\saves\mods
# for this isolated test package. A root-level /mods directory is not sufficient.
& (Join-Path $PSScriptRoot 'stage-mod.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'RTT mod staging failed.'
}
$StagedMod = Join-Path $RepoRoot 'out/mods/return-to-tristram'
$RuntimeModsDir = Join-Path $SaveDir 'mods'
$RuntimeRttModDir = Join-Path $RuntimeModsDir 'return-to-tristram'
New-Item -ItemType Directory -Force -Path $RuntimeRttModDir | Out-Null

# Seed the active mod with exact pinned engine logic assets, then overlay RTT.
Copy-Item (Join-Path $EngineAssetsDir '*') $RuntimeRttModDir -Recurse -Force
Copy-Item (Join-Path $StagedMod '*') $RuntimeRttModDir -Recurse -Force

$RequiredModAssets = @(
    'manifest.ini',
    'lua/inspect.lua',
    'lua/devilutionx/events.lua',
    'lua/mods/rtt/init.lua',
    'txtdata/classes/warrior/starting_loadout.tsv'
)
foreach ($relative in $RequiredModAssets) {
    $path = Join-Path $RuntimeRttModDir $relative
    if (-not (Test-Path $path)) {
        throw "RTT active runtime missing required file: saves/mods/return-to-tristram/$relative"
    }
}

$WarriorLoadout = Join-Path $RuntimeRttModDir 'txtdata/classes/warrior/starting_loadout.tsv'
if (-not (Select-String -Path $WarriorLoadout -Pattern '^gold\t100000$' -Quiet)) {
    throw 'Active RTT Warrior starting_loadout.tsv does not contain gold=100000.'
}

@"
[Mods]
return-to-tristram=1
"@ | Set-Content -Path (Join-Path $ConfigDir 'diablo.ini') -Encoding ASCII

$Launcher = @'
@echo off
setlocal
cd /d "%~dp0"

if not exist "DIABDAT.MPQ" if not exist "diabdat.mpq" (
  echo.
  echo ============================================================
  echo  RETURN TO TRISTRAM - brak DIABDAT.MPQ
  echo ============================================================
  echo.
  echo Skopiuj legalnie posiadany plik DIABDAT.MPQ z Diablo 1
  echo do tego samego katalogu co START_RTT_TEST.bat.
  echo.
  pause
  exit /b 2
)

if not exist "config" mkdir "config"
if not exist "saves" mkdir "saves"

echo Uruchamianie Return to Tristram...
"devilutionx.exe" --data-dir "." --save-dir ".\saves" --config-dir ".\config" --diablo -n
set EXITCODE=%ERRORLEVEL%

echo.
echo DevilutionX zakonczyl dzialanie z kodem %EXITCODE%.
pause
exit /b %EXITCODE%
'@
$Launcher | Set-Content -Path (Join-Path $PackageDir 'START_RTT_TEST.bat') -Encoding ASCII

$Readme = @"
RETURN TO TRISTRAM — WINDOWS x64 TEST BUILD
Version: $Version
RTT commit: $RttCommit

Ta paczka NIE zawiera danych gry Diablo firmy Blizzard.

URUCHOMIENIE
1. Rozpakuj ZIP do zwyklego katalogu, np. C:\Games\ReturnToTristram-Test
2. Skopiuj swoj legalnie posiadany DIABDAT.MPQ z Diablo 1 do katalogu paczki.
3. Opcjonalnie podlacz kontroler Xbox / kompatybilny XInput.
4. Uruchom START_RTT_TEST.bat.

WAZNE
Aktywny mod RTT znajduje sie w .\saves\mods\return-to-tristram, poniewaz
--save-dir .\saves ustawia ten katalog jako DevilutionX PrefPath.
Nowa postac Warrior/Rogue/Sorcerer powinna zaczynac z 100000 gold
(tymczasowo podniesione z wanilijnych 200 na czas testow Item UX/
Salvage/Crafting - trzeba miec zapas na Horadric Knowledge u Caina,
5000-400000 gold za poziom).

UWAGA O ASSETACH
Ta paczka zawiera dokladny loose asset tree z przypietego commita DevilutionX.
Binarka i Lua/TSV/UI assets sa z tej samej rewizji.

CO SPRAWDZIC W PHASE 1
- Nowa postac zaczyna z 100000 gold (potwierdzenie, ze RTT naprawde sie zaladowal).
- Return to Tristram jest aktywny jako mod.
- Nowa gra dochodzi do Tristram.
- Da sie wejsc do Cathedral Level 1.
- Walka dziala poprawnie.
- Loot filter RTT dziala i nie usuwa przedmiotow ze swiata.
- Wyswietlanie odpornosci/immunitetow potworow dziala.
- Zapis gry powstaje w izolowanym katalogu .\saves i daje sie ponownie wczytac.
- Kontroler dziala w menu, ruchu, walce i ekwipunku.
- Na koniec wykonaj podstawowy test multiplayer na dwoch klientach.

Jesli Windows SmartScreen ostrzeze o niepodpisanym buildzie developerskim,
to oczekiwane dla tej paczki CI. Kod zrodlowy odpowiada commitowi zapisanemu
w BUILD_INFO.txt.
"@
$Readme | Set-Content -Path (Join-Path $PackageDir 'README_TEST_PL.txt') -Encoding UTF8

$ExeHash = (Get-FileHash (Join-Path $PackageDir 'devilutionx.exe') -Algorithm SHA256).Hash
$InspectHash = (Get-FileHash (Join-Path $LooseAssetsDir 'lua/inspect.lua') -Algorithm SHA256).Hash
$AssetsVersion = (Get-Content (Join-Path $LooseAssetsDir 'ASSETS_VERSION') -Raw).Trim()
$BuildInfo = @"
Return to Tristram Windows x64 test package
Version: $Version
RTT commit: $RttCommit
DevilutionX commit: $EngineCommit
Configuration: $Configuration
Generated UTC: $([DateTime]::UtcNow.ToString('o'))
devilutionx.exe SHA256: $ExeHash
Pinned assets mode: $AssetsMode
Pinned ASSETS_VERSION: $AssetsVersion
assets/lua/inspect.lua SHA256: $InspectHash
Active RTT mod path: saves/mods/return-to-tristram
Active RTT Warrior starting gold verified: 100000 (temporary, Item UX/Salvage/Crafting testing)
Proprietary Diablo game data included: NO
"@
$BuildInfo | Set-Content -Path (Join-Path $PackageDir 'BUILD_INFO.txt') -Encoding UTF8

Write-Host "Creating ZIP: $ZipPath"
Compress-Archive -Path (Join-Path $PackageDir '*') -DestinationPath $ZipPath -CompressionLevel Optimal
if (-not (Test-Path $ZipPath)) {
    throw 'Windows test ZIP was not created.'
}

$ZipHash = (Get-FileHash $ZipPath -Algorithm SHA256).Hash
Write-Host "Package: $ZipPath"
Write-Host "SHA256: $ZipHash"
