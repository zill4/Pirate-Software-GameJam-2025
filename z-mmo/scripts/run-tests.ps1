param(
    [ValidateSet("basic", "unit", "integration", "benchmark", "all")]
    [string]$Level = "basic",
    [switch]$bench
)

Write-Host "Running $Level tests..."

switch ($Level) {
    "basic" {
        # Just compilation check
        & "$PSScriptRoot\check-build.ps1"
    }
    "unit" {
        # Run lightweight unit tests
        $subsystems = @("network", "physics", "game", "blockchain")
        foreach ($system in $subsystems) {
            if (Test-Path "src/$system/tests.zig") {
                Write-Host "`nRunning $system unit tests..."
                zig test "src/$system/tests.zig"
            }
        }
    }
    "integration" {
        # Run engine and integration tests
        Write-Host "`nRunning engine tests..."
        zig test "src/engine/tests.zig"
        Write-Host "`nRunning integration tests..."
        zig test "src/main.zig"
    }
    "benchmark" {
        # Run performance tests
        Write-Host "`nRunning benchmarks..."
        zig test "src/tests/benchmarks.zig" --bench
    }
    "all" {
        # Run everything
        & "$PSScriptRoot\run-tests.ps1" -Level "unit"
        & "$PSScriptRoot\run-tests.ps1" -Level "integration"
        & "$PSScriptRoot\run-tests.ps1" -Level "benchmark"
    }
}