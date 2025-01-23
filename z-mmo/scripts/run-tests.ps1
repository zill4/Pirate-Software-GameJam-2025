param(
    [ValidateSet("basic", "unit", "integration", "all")]
    [string]$Level = "basic"
)

Write-Host "Running $Level tests..."

switch ($Level) {
    "basic" {
        # Just compilation check
        & "$PSScriptRoot\check-build.ps1"
    }
    "unit" {
        # Run all unit tests through build.zig
        Write-Host "`nRunning unit tests..."
        zig build test
    }
    "integration" {
        # Run integration tests through build.zig
        Write-Host "`nRunning integration tests..."
        zig build test -Dtest-filter="integration"
    }
    "all" {
        # Run all tests through build.zig
        Write-Host "`nRunning all tests..."
        zig build test
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ All $Level tests passed!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Some tests failed!" -ForegroundColor Red
    exit 1
}