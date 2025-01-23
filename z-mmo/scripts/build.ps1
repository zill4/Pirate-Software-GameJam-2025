param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Debug", "Release")]
    [string]$Config,
    
    [Parameter(Mandatory=$false)]
    [string]$TestFilter = ""
)

$buildArgs = @(
    "build",
    "-Dtarget=x86_64-windows",
    "-Doptimize=$Config"
)

if ($Config -eq "Debug") {
    $buildArgs += @(
        "-Dlogging=true",
        "-Dprofile=true"
    )
}

if ($TestFilter) {
    $buildArgs += "-Dtest-filter=$TestFilter"
}

Write-Host "Building with config: $Config"
& zig $buildArgs
