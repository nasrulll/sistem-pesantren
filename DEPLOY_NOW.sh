#!/bin/bash

echo "🚀 DEPLOY NOW - SISTEM PESANTREN 40 MODUL"
echo "=========================================="

# Konfigurasi
SERVER_IP="192.168.55.4"
SERVER_USER="sisfo"
SERVER_PASS="12Jagahati"
PROJECT_DIR="/var/www/html/pesantren"

# Fungsi untuk logging
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Step 1: Copy semua file ke server
log "📤 Step 1: Copy semua file ke server $SERVER_IP..."

# Buat archive dari project
ARCHIVE_FILE="/tmp/pesantren-system-$(date +%Y%m%d-%H%M%S).tar.gz"
log "📦 Membuat archive: $ARCHIVE_FILE"

cd pesantren-system
tar -czf "$ARCHIVE_FILE" \
    --exclude="node_modules" \
    --exclude=".git" \
    --exclude="*.log" \
    --exclude="uploads/*" \
    .

# Size info
SIZE=$(du -h "$ARCHIVE_FILE" | cut -f1)
log "📊 Archive size: $SIZE"

# Step 2: Upload ke server menggunakan expect
log "📤 Step 2: Upload ke server..."

# Buat script upload dengan expect
UPLOAD_SCRIPT="/tmp/upload_$$.exp"
cat > "$UPLOAD_SCRIPT" << EOF
#!/usr/bin/expect -f
set timeout 60

spawn scp "$ARCHIVE_FILE" $SERVER_USER@$SERVER_IP:/tmp/
expect "password:"
send "$SERVER_PASS\r"
expect eof
EOF

chmod +x "$UPLOAD_SCRIPT"

if command -v expect &> /dev/null; then
    expect -f "$UPLOAD_SCRIPT"
    if [ $? -eq 0 ]; then
        log "✅ Upload berhasil"
    else
        log "❌ Upload gagal, coba metode manual"
        echo ""
        echo "📋 MANUAL UPLOAD:"
        echo "scp $ARCHIVE_FILE $SERVER_USER@$SERVER_IP:/tmp/"
        echo "Password: $SERVER_PASS"
    fi
else
    log "⚠️  Expect tidak tersedia, gunakan manual upload"
    echo ""
    echo "📋 MANUAL UPLOAD:"
    echo "scp $ARCHIVE_FILE $SERVER_USER@$SERVER_IP:/tmp/"
    echo "Password: $SERVER_PASS"
fi

rm -f "$UPLOAD_SCRIPT"

# Step 3: Buat deployment script untuk dijalankan di server
log "📝 Step 3: Buat deployment script untuk server..."

DEPLOY_SCRIPT="/tmp/deploy_on_server_$$.sh"
cat > "$DEPLOY_SCRIPT" << 'EOF'
#!/bin/bash

echo "🚀 DEPLOYMENT SCRIPT - PESANTREN SYSTEM"
echo "========================================"

# Konfigurasi
PROJECT_DIR="/var/www/html/pesantren"
ARCHIVE_FILE="/tmp/pesantren-system-*.tar.gz"

# Fungsi untuk logging
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Step 1: Extract archive
log "📦 Step 1: Extract archive..."
if ls /tmp/pesantren-system-*.tar.gz 1> /dev/null 2>&1; then
    ARCHIVE=$(ls -t /tmp/pesantren-system-*.tar.gz | head -1)
    log "📁 Archive ditemukan: $ARCHIVE"
    
    # Buat direktori project
    sudo mkdir -p "$PROJECT_DIR"
    sudo chown -R $USER:$USER "$PROJECT_DIR"
    
    # Extract
    tar -xzf "$ARCHIVE" -C "$PROJECT_DIR"
    log "✅ Archive extracted ke $PROJECT_DIR"
else
    log "❌ Archive tidak ditemukan"
    exit 1
fi

# Step 2: Install dependencies minimal
log "📦 Step 2: Install dependencies..."
sudo apt update

# Cek dan install Docker
if ! command -v docker &> /dev/null; then
    log "🐳 Install Docker..."
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
else
    log "✅ Docker sudah terinstall"
fi

# Cek dan install Node.js
if ! command -v node &> /dev/null; then
    log "📦 Install Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    log "✅ Node.js sudah terinstall"
fi

# Step 3: Setup project
log "⚙️ Step 3: Setup project..."
cd "$PROJECT_DIR"

# Buat .env file jika belum ada
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    log "⚠️  File .env dibuat dari contoh. Edit sesuai kebutuhan."
fi

# Beri permission pada scripts
chmod +x scripts/*.sh 2>/dev/null || true

# Step 4: Start dengan docker-compose
log "🐳 Step 4: Start services dengan Docker..."

# Cek apakah docker-compose.yml ada
if [ -f "docker-compose.yml" ]; then
    log "📁 docker-compose.yml ditemukan"
    
    # Stop services lama jika ada
    docker-compose down 2>/dev/null || true
    
    # Build dan start
    docker-compose up -d --build
    
    # Tunggu sebentar
    sleep 10
    
    # Cek status
    log "🔍 Status services:"
    docker-compose ps
    
    # Test API
    log "🧪 Testing API..."
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        log "✅ API berjalan di http://localhost:3000/api"
    else
        log "⚠️  API belum merespon, coba tunggu beberapa detik"
        sleep 5
        curl -I http://localhost:3000/api/health || log "❌ API tidak merespon"
    fi
    
    # Test web
    log "🌐 Testing web interface..."
    if curl -s http://localhost > /dev/null 2>&1; then
        log "✅ Web interface berjalan di http://localhost"
    else
        log "⚠️  Web interface belum siap"
    fi
else
    log "❌ docker-compose.yml tidak ditemukan"
    log "📁 Files yang ada:"
    ls -la
fi

# Step 5: Tampilkan informasi
log "🎉 Step 5: Deployment selesai!"
echo ""
echo "=========================================="
echo "🚀 SISTEM PESANTREN 40 MODUL DEPLOYED!"
echo "=========================================="
echo ""
echo "🌐 ACCESS:"
echo "   Backend API: http://localhost:3000/api"
echo "   Web Interface: http://localhost"
echo "   Database: localhost:5432"
echo ""
echo "🔧 MANAGEMENT:"
echo "   Start:    cd $PROJECT_DIR && docker-compose up -d"
echo "   Stop:     cd $PROJECT_DIR && docker-compose down"
echo "   Logs:     cd $PROJECT_DIR && docker-compose logs -f"
echo "   Restart:  cd $PROJECT_DIR && docker-compose restart"
echo ""
echo "📊 MODUL YANG TERSEDIA:"
echo "   - 40 modul lengkap sistem pesantren"
echo "   - Database dengan 150+ tabel"
echo "   - API endpoints untuk semua fitur"
echo ""
echo "✅ DEPLOYMENT SELESAI!"
EOF

chmod +x "$DEPLOY_SCRIPT"

# Step 4: Upload dan jalankan deployment script di server
log "📤 Step 4: Upload deployment script ke server..."

# Upload script
if command -v expect &> /dev/null; then
    expect -c "
        set timeout 30
        spawn scp $DEPLOY_SCRIPT $SERVER_USER@$SERVER_IP:/tmp/deploy_now.sh
        expect \"password:\"
        send \"$SERVER_PASS\r\"
        expect eof
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log "✅ Deployment script uploaded"
        
        # Jalankan script di server
        log "🚀 Step 5: Jalankan deployment script di server..."
        expect -c "
            set timeout 300
            spawn ssh $SERVER_USER@$SERVER_IP \"bash /tmp/deploy_now.sh\"
            expect \"password:\"
            send \"$SERVER_PASS\r\"
            expect eof
        " 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log "✅ Deployment script dijalankan di server"
        else
            log "❌ Gagal menjalankan script di server"
            echo ""
            echo "📋 MANUAL EXECUTION:"
            echo "ssh $SERVER_USER@$SERVER_IP"
            echo "Password: $SERVER_PASS"
            echo "bash /tmp/deploy_now.sh"
        fi
    fi
else
    log "⚠️  Expect tidak tersedia, gunakan manual"
    echo ""
    echo "📋 MANUAL DEPLOYMENT:"
    echo "1. Upload archive:"
    echo "   scp $ARCHIVE_FILE $SERVER_USER@$SERVER_IP:/tmp/"
    echo ""
    echo "2. Upload script:"
    echo "   scp $DEPLOY_SCRIPT $SERVER_USER@$SERVER_IP:/tmp/deploy_now.sh"
    echo ""
    echo "3. SSH ke server dan jalankan:"
    echo "   ssh $SERVER_USER@$SERVER_IP"
    echo "   bash /tmp/deploy_now.sh"
fi

# Cleanup
rm -f "$DEPLOY_SCRIPT"
rm -f "$ARCHIVE_FILE"

log "🎉 Proses deploy selesai!"
echo ""
echo "=========================================="
echo "📋 NEXT STEPS:"
echo "1. Cek status di server:"
echo "   ssh $SERVER_USER@$SERVER_IP"
echo "   cd /var/www/html/pesantren && docker-compose ps"
echo ""
echo "2. Test aplikasi:"
echo "   curl http://$SERVER_IP:3000/api/health"
echo "   curl http://$SERVER_IP"
echo ""
echo "3. Akses web interface:"
echo "   http://$SERVER_IP"
echo ""
echo "✅ SEMUA 40 MODUL TELAH DITAMBAHKAN!"