param([switch]$FullEngine)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$cmake = Get-Command cmake -ErrorAction SilentlyContinue
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs) { throw 'Install Visual Studio C++ Build Tools and Windows SDK.' }
if ($cmake) { $cmakePath = $cmake.Source } else {
    $cmakePath = Join-Path $vs 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
}
if (-not (Test-Path -LiteralPath $cmakePath)) { throw 'CMake 3.20+ is required.' }
$ctestPath = Join-Path (Split-Path $cmakePath) 'ctest.exe'
function Invoke-Checked([string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Exe failed with exit code $LASTEXITCODE" }
}
Push-Location $repo
try {
    Invoke-Checked git @('submodule', 'update', '--init', '--recursive')
    $revision = & git -C engine/abyss rev-parse HEAD
    if ($revision -ne '885eea067f0d41a4fb75de2e88b3704215859a58') { throw 'Unexpected Abyss revision.' }
    Invoke-Checked $cmakePath @('-S', '.', '-B', 'build/bootstrap', '-A', 'x64')
    Invoke-Checked $cmakePath @('--build', 'build/bootstrap', '--config', 'Release')
    Invoke-Checked $ctestPath @('--test-dir', 'build/bootstrap', '-C', 'Release', '--output-on-failure')
    Invoke-Checked python @('-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py')
    if ($FullEngine) {
        $vcpkg = Join-Path $repo 'build/vcpkg'
        if (-not (Test-Path -LiteralPath $vcpkg)) {
            Invoke-Checked git @('clone', 'https://github.com/microsoft/vcpkg.git', $vcpkg)
            Invoke-Checked git @('-C', $vcpkg, 'checkout', '--detach', '04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4')
        }
        if ((& git -C $vcpkg rev-parse HEAD) -ne '04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4') {
            throw 'vcpkg checkout must be at 04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4.'
        }
        $vcpkgExe = Join-Path $vcpkg 'vcpkg.exe'
        $toolVersion = if (Test-Path -LiteralPath $vcpkgExe) { (& $vcpkgExe version) -join ' ' } else { '' }
        if ($toolVersion -notmatch '2026-07-27-') {
            Invoke-Checked (Join-Path $vcpkg 'bootstrap-vcpkg.bat') @('-disableMetrics')
        }
        Invoke-Checked $cmakePath @('-S', 'engine/abyss', '-B', 'build/abyss-vcpkg', '-A', 'x64',
            "-DCMAKE_TOOLCHAIN_FILE=$vcpkg/scripts/buildsystems/vcpkg.cmake", '-DVCPKG_TARGET_TRIPLET=x64-windows', '-DGITHUB_ACTIONS=1')
        Invoke-Checked $cmakePath @('--build', 'build/abyss-vcpkg', '--config', 'Release')
        Invoke-Checked $ctestPath @('--test-dir', 'build/abyss-vcpkg', '-C', 'Release', '--output-on-failure')
    }
} finally { Pop-Location }
