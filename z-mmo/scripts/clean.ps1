Write-Host "Cleaning build artifacts..."
if (Test-Path "zig-cache") { Remove-Item -Recurse -Force "zig-cache" }
if (Test-Path "zig-out") { Remove-Item -Recurse -Force "zig-out" }