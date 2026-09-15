param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release',
    [string]$VcpkgRoot = $env:VCPKG_ROOT,
    [string]$Sol2Source = $env:RTT_SOL2_SOURCE
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
    '-DBUILD_TESTING=ON'
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

if ($Sol2Source) {
    $Sol2CMake = Join-Path $Sol2Source 'CMakeLists.txt'
    if (-not (Test-Path $Sol2CMake)) {
        throw "Prefetched sol2 source is invalid: $Sol2Source"
    }
    $ResolvedSol2 = (Resolve-Path $Sol2Source).Path -replace '\\', '/'
    $ConfigureArgs += "-DFETCHCONTENT_SOURCE_DIR_SOL2=$ResolvedSol2"
    Write-Host "Using prefetched sol2: $ResolvedSol2"
}

cmake @ConfigureArgs
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed with exit code $LASTEXITCODE"
}

cmake --build $BuildDir --config $Configuration --target devilutionx rtt_phase4_test --parallel
if ($LASTEXITCODE -ne 0) {
    throw "DevilutionX build failed with exit code $LASTEXITCODE"
}

Write-Host "Build complete: $BuildDir"
