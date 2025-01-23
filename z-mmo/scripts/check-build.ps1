Write-Host "Running basic compilation check..."

# For Zig 0.13.0, we'll use -Doptimize=Debug to do a quick compilation check
zig build -Doptimize=Debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Basic compilation check passed!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Compilation check failed!" -ForegroundColor Red
    exit 1
} 