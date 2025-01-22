param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Debug", "Release")]
    [string]$Config
)

$buildArgs = @(
    "build",
    "-Dtarget=x86_64-windows",
    "-Doptimize=$Config",
    "-Dgraphics=dx12"
)

if ($Config -eq "Debug") {
    $buildArgs += @(
        "-Dlogging=true",
        "-Dprofile=true"
    )
}

Write-Host "Building with config: $Config"
& zig $buildArgs
