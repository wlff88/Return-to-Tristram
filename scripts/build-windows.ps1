param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release',
    [string]$VcpkgRoot = $env:VCPKG_ROOT
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourceDir = Join-Path $RepoRoot 'Engine/devilutionx'
$BuildDir = Join-Path $RepoRoot 'build/devilutionx-windows-x64'

if (-not (Test-Path (Join-Path $SourceDir 'CMakeLists.txt'))) {
    throw 'DevilutionX submodule is missing. Run scripts/bootstrap-devilutionx.ps1 first.'
}

python (Join-Path $PSScriptRoot 'apply-engine-patches.py')
if ($LASTEXITCODE -ne 0) {
    throw 'RTT engine patch application failed.'
}

$ConfigureArgs = @(
    '-S', $SourceDir,
    '-B', $BuildDir,
    '-A', 'x64',
    '-DBUILD_TESTING=OFF'
)

if ($VcpkgRoot) {
    $Toolchain = Join-Path $VcpkgRoot 'scripts/buildsystems/vcpkg.cmake'
    if (-not (Test-Path $Toolchain)) {
        throw "Vcpkg toolchain not found at $Toolchain"
    }
    $ConfigureArgs += "-DCMAKE_TOOLCHAIN_FILE=$Toolchain"
}
else {
    Write-Warning 'VCPKG_ROOT is not set. CMake will try to resolve dependencies using the local environment.'
}

cmake @ConfigureArgs
cmake --build $BuildDir --config $Configuration --target devilutionx --parallel

Write-Host "Build complete: $BuildDir"
