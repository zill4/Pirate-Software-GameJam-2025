Write-Host "🔍 Running CI checks locally..." -ForegroundColor Cyan

Write-Host "`n📦 Building debug version..." -ForegroundColor Yellow
make build-debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Debug build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
make test-all
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ All CI checks passed!" -ForegroundColor Green 