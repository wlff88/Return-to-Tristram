param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release',
    [string]$DevilutionXAssetsUrl = 'https://github.com/diasurgical/devilutionx-assets/releases/latest/download/devilutionx.mpq'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BuildDir = Join-Path $RepoRoot 'build/devilutionx-windows-x64'
$OutRoot = Join-Path $RepoRoot 'out/windows-test-build'
$Version = (Get-Content (Join-Path $RepoRoot 'VERSION') -Raw).Trim()
$PackageName = "Return-to-Tristram-$Version-Windows-x64-test"
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

Write-Host "Packaging runtime from: $RuntimeSourceDir"

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

# Stage the exact RTT runtime package and place it in the loose-mod directory
# used by the pinned DevilutionX baseline.
& (Join-Path $PSScriptRoot 'stage-mod.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'RTT mod staging failed.'
}
$StagedMod = Join-Path $RepoRoot 'out/mods/return-to-tristram'
$RuntimeModsDir = Join-Path $PackageDir 'mods'
New-Item -ItemType Directory -Force -Path $RuntimeModsDir | Out-Null
Copy-Item $StagedMod (Join-Path $RuntimeModsDir 'return-to-tristram') -Recurse -Force

# A source build does not necessarily generate devilutionx.mpq. Use the official
# DevilutionX asset bundle when it is not already present in the build output.
$AssetsPath = Join-Path $PackageDir 'devilutionx.mpq'
$ExistingAssets = Get-ChildItem -Path $BuildDir -Filter 'devilutionx.mpq' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -ne $ExistingAssets) {
    Copy-Item $ExistingAssets.FullName $AssetsPath -Force
    $AssetsSource = "build:$($ExistingAssets.FullName)"
} else {
    Write-Host "Downloading official DevilutionX runtime assets..."
    Invoke-WebRequest -Uri $DevilutionXAssetsUrl -OutFile $AssetsPath -UseBasicParsing
    $AssetsSource = $DevilutionXAssetsUrl
}
if (-not (Test-Path $AssetsPath)) {
    throw 'devilutionx.mpq is missing from the test package.'
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

Ta paczka NIE zawiera danych gry Diablo firmy Blizzard.

URUCHOMIENIE
1. Rozpakuj ZIP do zwyklego katalogu, np. C:\Games\ReturnToTristram-Test
2. Skopiuj swoj legalnie posiadany DIABDAT.MPQ z Diablo 1 do katalogu paczki.
3. Opcjonalnie podlacz kontroler Xbox / kompatybilny XInput.
4. Uruchom START_RTT_TEST.bat.

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

$RttCommit = (git -C $RepoRoot rev-parse HEAD).Trim()
$EngineCommit = (git -C (Join-Path $RepoRoot 'Engine/devilutionx') rev-parse HEAD).Trim()
$ExeHash = (Get-FileHash (Join-Path $PackageDir 'devilutionx.exe') -Algorithm SHA256).Hash
$AssetsHash = (Get-FileHash $AssetsPath -Algorithm SHA256).Hash
$BuildInfo = @"
Return to Tristram Windows x64 test package
Version: $Version
RTT commit: $RttCommit
DevilutionX commit: $EngineCommit
Configuration: $Configuration
Generated UTC: $([DateTime]::UtcNow.ToString('o'))
devilutionx.exe SHA256: $ExeHash
devilutionx.mpq SHA256: $AssetsHash
devilutionx.mpq source: $AssetsSource
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
