param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release',
    [string]$VcpkgRoot = $env:VCPKG_ROOT,
    [string]$Sol2Source = $env:RTT_SOL2_SOURCE,
    # Opt-in only: switches the generator from the default Visual Studio
    # (MSBuild) project to Ninja. A plain developer workstation keeps the
    # existing VS-generator behavior (no vcvarsall/Developer Prompt required)
    # unless it explicitly asks for Ninja.
    [switch]$Ninja
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
    '-DBUILD_TESTING=ON',
    # DevilutionX's own CMakeLists.txt force-disables BUILD_TESTING for a
    # non-Debug MSVC configuration when LTO is on (workaround for a MSVC+CMake
    # LTO bug, https://github.com/diasurgical/devilutionX/issues/3778). That
    # silently drops every test target, including rtt_phase4_test, so the
    # contract gate never builds. Disable LTO for this baseline/test build so
    # BUILD_TESTING actually takes effect.
    '-DDISABLE_LTO=ON'
)

if ($Ninja) {
    # Ninja is single-config: the build type has to be fixed at configure
    # time instead of chosen later via `cmake --build --config`.
    $ConfigureArgs += '-G', 'Ninja'
    $ConfigureArgs += "-DCMAKE_BUILD_TYPE=$Configuration"
}
else {
    $ConfigureArgs += '-A', 'x64'
}

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

# No compiler-cache wiring needed here: DevilutionX's own CMakeLists.txt
# already does `find_program(CCACHE_PROGRAM ccache)` and sets
# CMAKE_C/CXX_COMPILER_LAUNCHER itself when ccache is on PATH. That hook is
# only implemented by CMake for the Makefile/Ninja generators (not Visual
# Studio/MSBuild), which is exactly why -Ninja exists above -- so a CI job
# that installs ccache and passes -Ninja gets a working compiler cache for
# free, matching upstream DevilutionX's own Windows_MSVC_x64.yml.
cmake @ConfigureArgs
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed with exit code $LASTEXITCODE"
}

cmake --build $BuildDir --config $Configuration --target devilutionx rtt_phase4_test --parallel
if ($LASTEXITCODE -ne 0) {
    throw "DevilutionX build failed with exit code $LASTEXITCODE"
}

Write-Host "Build complete: $BuildDir"
