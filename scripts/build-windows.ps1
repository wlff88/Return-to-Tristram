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
    '-DBUILD_TESTING=ON',
    # DevilutionX's own CMakeLists.txt force-disables BUILD_TESTING for a
    # non-Debug MSVC configuration when LTO is on (workaround for a MSVC+CMake
    # LTO bug, https://github.com/diasurgical/devilutionX/issues/3778). That
    # silently drops every test target, including rtt_phase4_test, so the
    # contract gate never builds. Disable LTO for this baseline/test build so
    # BUILD_TESTING actually takes effect.
    '-DDISABLE_LTO=ON'
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

# Opt-in, not required: only wire sccache in when it is on PATH (CI installs
# it explicitly) so a developer workstation without it builds exactly as
# before. CMAKE_<LANG>_COMPILER_LAUNCHER is a no-op here -- CMake only
# implements that hook for the Makefile/Ninja generators, not the Visual
# Studio (MSBuild) generator this script uses (-A x64 with no -G). Instead,
# stand a renamed copy of sccache in for MSBuild's own ClCompile tool: sccache
# recognizes it was invoked as "cl.exe" and resolves the real compiler itself
# from PATH, which the CI job's msvc-dev-cmd step puts there.
$Sccache = Get-Command sccache -ErrorAction SilentlyContinue
if ($Sccache) {
    $WrapperDir = Join-Path ([System.IO.Path]::GetTempPath()) 'rtt-sccache-cl'
    if (Test-Path $WrapperDir) {
        Remove-Item -Recurse -Force $WrapperDir
    }
    New-Item -ItemType Directory -Force -Path $WrapperDir | Out-Null
    Copy-Item $Sccache.Source (Join-Path $WrapperDir 'cl.exe') -Force

    $VsGlobals = "CLToolExe=cl.exe;CLToolPath=$WrapperDir;TrackFileAccess=false;UseMultiToolTask=true"
    $ConfigureArgs += "-DCMAKE_VS_GLOBALS=$VsGlobals"
    Write-Host "sccache found: enabling MSBuild compiler cache via $WrapperDir"
}
else {
    Write-Host "sccache not found on PATH: building without a compiler cache"
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
