param(
    [switch]$bench
)

Write-Host "Running tests..."
# Only run tests that don't require DirectX
& zig test src/core/tests.zig

if ($bench) {
    zig build test --bench
} else {
    zig build test
}