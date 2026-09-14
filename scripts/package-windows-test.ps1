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

# Visual Studio/vcpkg puts the executable and app-local runtime DLLs together.
Copy-Item (Join-Path $RuntimeSourceDir '*') $PackageDir -Recurse -Force

if (-not (Test-Path (Join-Path $PackageDir 'devilutionx.exe'))) {
    throw 'Packaged runtime is missing devilutionx.exe.'
}

# IMPORTANT: keep engine binary and engine assets on the same pinned revision.
# The previous test package downloaded the latest public devilutionx.mpq when the
# source build did not produce one. That can version-skew a development binary
# from its Lua/TSV assets (for example assets/lua/inspect.lua).
#
# Always ship the exact pinned source asset tree as a loose /assets directory.
# DevilutionX explicitly supports this directory next to the executable as a
# runtime fallback. If the build also produced devilutionx.mpq, include it too;
# because it was generated from the same pinned source it is safe to pair with
# this binary.
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
    # Deliberately do NOT download releases/latest/devilutionx.mpq here. The
    # current RTT engine is pinned to a development commit and must use assets
    # from that exact same commit.
    $AssetsMode = 'pinned-loose-assets (no external devilutionx.mpq fallback)'
}

# Stage the exact RTT runtime package. Start with the pinned engine asset tree as
# a complete loose runtime overlay, then place RTT files on top. This gives the
# active RTT mod exact-version Lua/TSV data while preserving RTT overrides.
& (Join-Path $PSScriptRoot 'stage-mod.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'RTT mod staging failed.'
}
$StagedMod = Join-Path $RepoRoot 'out/mods/return-to-tristram'
$RuntimeModsDir = Join-Path $PackageDir 'mods'
$RuntimeRttModDir = Join-Path $RuntimeModsDir 'return-to-tristram'
New-Item -ItemType Directory -Force -Path $RuntimeRttModDir | Out-Null
Copy-Item (Join-Path $EngineAssetsDir '*') $RuntimeRttModDir -Recurse -Force
Copy-Item (Join-Path $StagedMod '*') $RuntimeRttModDir -Recurse -Force

$RequiredModAssets = @(
    'manifest.ini',
    'lua/inspect.lua',
    'lua/devilutionx/events.lua',
    'lua/mods/rtt/init.lua'
)
foreach ($relative in $RequiredModAssets) {
    $path = Join-Path $RuntimeRttModDir $relative
    if (-not (Test-Path $path)) {
        throw "RTT runtime overlay missing required file: mods/return-to-tristram/$relative"
    }
}

$ConfigDir = Join-Path $PackageDir 'config'
$SaveDir = Join-Path $PackageDir 'saves'
New-Item -ItemType Directory -Force -Path $ConfigDir, $SaveDir | Out-Null
@"
[Mods]
return-to-tristram=true
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

UWAGA O ASSETACH
Ta paczka zawiera dokladny loose asset tree z przypietego commita DevilutionX.
Nie korzysta z losowego/latest asset bundle jako zamiennika dla builda developerskiego.
Dzieki temu binarka i Lua/TSV/UI assets sa z tej samej rewizji.

CO SPRAWDZIC W PHASE 1
- Return to Tristram jest aktywny jako mod.
- Nowa gra dochodzi do Tristram.
- Da sie wejsc do Cathedral Level 1.
- Walka dziala poprawnie.
- Loot filter RTT dziala i nie usuwa przedmiotow ze swiata.
- Wyswietlanie odpornosci/immunitetow potworow dziala.
- Zapis gry powstaje w izolowanym katalogu .\saves i daje sie ponownie wczytac.
- Kontroler dziala w menu, ruchu, walce i ekwipunku.
- Na koniec wykonaj podstawowy test multiplayer na dwoch klientach.

Paczka uzywa wlasnych katalogow .\config i .\saves, wiec nie powinna zmieniac
Twojej standardowej konfiguracji ani save'ow DevilutionX.

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
