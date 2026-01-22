# 🪟 Windows'tan Ubuntu Sunucusuna Deployment Script
# Kullanım: PowerShell'de çalıştır: .\deploy-from-windows.ps1

param(
    [string]$Server = "ubuntu@52.59.192.113",
    [string]$LocalPath = "C:\Users\Mustafa-Slayer\Documents\GitHub\sinema_uygulamasi\api_server",
    [string]$RemotePath = "/var/www/html/api_server"
)

Write-Host "🚀 Laravel Cinema App - Windows Deployment" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Kontroller
if (-not (Test-Path $LocalPath)) {
    Write-Host "❌ Hata: $LocalPath bulunamadı!" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Ayarlar:" -ForegroundColor Yellow
Write-Host "   Sunucu: $Server" -ForegroundColor Cyan
Write-Host "   Local: $LocalPath" -ForegroundColor Cyan
Write-Host "   Remote: $RemotePath" -ForegroundColor Cyan
Write-Host ""

# Onay
$confirm = Read-Host "Devam etmek istiyor musunuz? (y/n)"
if ($confirm -ne "y") {
    Write-Host "❌ İptal edildi" -ForegroundColor Red
    exit 0
}

# 1. Dosyaları Yükle
Write-Host ""
Write-Host "📦 Dosyalar yükleniyor..." -ForegroundColor Yellow
try {
    scp -r "$LocalPath\*" "${Server}:${RemotePath}/"
    Write-Host "✅ Dosyalar yüklendi" -ForegroundColor Green
} catch {
    Write-Host "❌ Dosya yükleme hatası: $_" -ForegroundColor Red
    exit 1
}

# 2. SSH ile Deployment
Write-Host ""
Write-Host "🚀 Sunucuda deployment başlatılıyor..." -ForegroundColor Yellow
Write-Host "   (SSH şifresi istenebilir)" -ForegroundColor Gray

$deployCommands = @"
cd $RemotePath
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 775 storage bootstrap/cache
if [ -f deploy.sh ]; then
    sudo bash deploy.sh
else
    echo '⚠️  deploy.sh bulunamadı, manuel kurulum gerekli'
fi
"@

try {
    ssh $Server $deployCommands
    Write-Host ""
    Write-Host "✅ Deployment tamamlandı!" -ForegroundColor Green
} catch {
    Write-Host "❌ Deployment hatası: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Manuel olarak SSH ile bağlanın:" -ForegroundColor Yellow
    Write-Host "   ssh $Server" -ForegroundColor Cyan
    Write-Host "   cd $RemotePath" -ForegroundColor Cyan
    Write-Host "   sudo bash deploy.sh" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📝 Sonraki adımlar:" -ForegroundColor Yellow
Write-Host "   1. SSH ile bağlan: ssh $Server" -ForegroundColor Cyan
Write-Host "   2. .env dosyasını düzenle: sudo nano $RemotePath/.env" -ForegroundColor Cyan
Write-Host "   3. Veritabanı migration: cd $RemotePath && php artisan migrate --force" -ForegroundColor Cyan
Write-Host "   4. Veritabanı seeding: php artisan db:seed --force" -ForegroundColor Cyan
Write-Host ""
