#!/bin/bash

echo "🤖 SCRIPT OTOMATIS: IDENTIFIKASI & PENAMBAHAN MODUL"
echo "==================================================="

# Konfigurasi
TARGET_SERVER="192.168.55.4"
TARGET_USER="sisfo"
TARGET_PASSWORD="12Jagahati"
BASE_DIR="/var/www/html/pesantren"
LOCAL_PROJECT_DIR="$(pwd)/pesantren-system"

# Fungsi untuk eksekusi remote command via SSH
remote_exec() {
    local cmd="$1"
    
    # Simpan command ke file
    local temp_script="/tmp/remote_script_$$.sh"
    echo "#!/bin/bash" > "$temp_script"
    echo "$cmd" >> "$temp_script"
    chmod +x "$temp_script"
    
    # Coba berbagai metode SSH
    echo "🔧 Executing remote command..."
    
    # Method 1: ssh dengan expect (jika tersedia)
    if command -v expect &> /dev/null; then
        expect -c "
            set timeout 30
            spawn scp $temp_script $TARGET_USER@$TARGET_SERVER:/tmp/remote_exec.sh
            expect \"password:\"
            send \"$TARGET_PASSWORD\r\"
            expect eof
            
            spawn ssh $TARGET_USER@$TARGET_SERVER \"bash /tmp/remote_exec.sh\"
            expect \"password:\"
            send \"$TARGET_PASSWORD\r\"
            expect eof
        " 2>/dev/null
    else
        echo "⚠️  Expect tidak tersedia, gunakan metode manual"
        echo "📋 Manual steps untuk admin:"
        echo "   1. ssh $TARGET_USER@$TARGET_SERVER"
        echo "   2. Password: $TARGET_PASSWORD"
        echo "   3. Jalankan command: $cmd"
    fi
    
    rm -f "$temp_script"
}

# Fungsi untuk deteksi sistem yang sudah ada
detect_existing_system() {
    echo "🔍 MENDETEKSI SISTEM YANG SUDAH ADA..."
    
    # Command untuk deteksi remote
    local detect_cmd=$(cat << 'EOF'
#!/bin/bash

echo "=== SYSTEM DETECTION REPORT ==="
echo "Generated: $(date)"
echo ""

# 1. Check web server
echo "1. WEB SERVER:"
if systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx: ACTIVE"
    echo "   Config:"
    nginx -T 2>/dev/null | grep -A5 "server_name" || echo "   (tidak ada config khusus)"
elif systemctl is-active --quiet apache2; then
    echo "   ✅ Apache2: ACTIVE"
else
    echo "   ❌ No web server detected"
fi
echo ""

# 2. Check database
echo "2. DATABASE:"
if systemctl is-active --quiet postgresql; then
    echo "   ✅ PostgreSQL: ACTIVE"
    # List databases
    echo "   Databases:"
    sudo -u postgres psql -lqt 2>/dev/null | awk '{print "     - "$1}' || echo "     (tidak bisa akses)"
elif systemctl is-active --quiet mysql; then
    echo "   ✅ MySQL: ACTIVE"
else
    echo "   ❌ No database detected"
fi
echo ""

# 3. Check project directories
echo "3. PROJECT DIRECTORIES:"
common_dirs=("/var/www/html" "/home/$USER/projects" "/opt" "/srv")
for dir in "${common_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "   📁 $dir:"
        find "$dir" -maxdepth 2 -type d -name "*pesantren*" -o -name "*santri*" -o -name "*pondok*" 2>/dev/null | head -5 | while read -r found; do
            echo "     - $found"
        done
    fi
done
echo ""

# 4. Check running services
echo "4. RUNNING SERVICES (relevant):"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | grep -i "pesantren\|santri\|pondok\|postgres\|nginx\|node" || echo "   (tidak ada service terkait)"
echo ""

# 5. Check installed packages
echo "5. INSTALLED PACKAGES:"
dpkg -l | grep -i "node\|npm\|docker\|postgres\|nginx" 2>/dev/null | head -10 || echo "   (tidak ada package terkait)"
echo ""

echo "=== END REPORT ==="
EOF
)
    
    remote_exec "$detect_cmd"
}

# Fungsi untuk copy project ke server
copy_project_to_server() {
    echo "📤 MENYALIN PROJECT KE SERVER..."
    
    if [ ! -d "$LOCAL_PROJECT_DIR" ]; then
        echo "❌ Local project directory tidak ditemukan: $LOCAL_PROJECT_DIR"
        return 1
    fi
    
    # Buat archive lokal
    local archive_file="/tmp/pesantren-system-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo "📦 Membuat archive: $archive_file"
    
    # Archive semua file kecuali yang besar/tidak perlu
    tar -czf "$archive_file" \
        -C "$LOCAL_PROJECT_DIR" \
        --exclude="node_modules" \
        --exclude=".git" \
        --exclude="*.log" \
        --exclude="uploads/*" \
        .
    
    # Size check
    local size=$(du -h "$archive_file" | cut -f1)
    echo "📊 Archive size: $size"
    
    # Upload command
    local upload_cmd=$(cat << EOF
#!/bin/bash

echo "📥 Menerima archive project..."
DEST_DIR="$BASE_DIR"
sudo mkdir -p "\$DEST_DIR"
sudo chown -R $TARGET_USER:$TARGET_USER "\$DEST_DIR"

# Note: File akan diupload manual oleh admin
echo "📋 Manual upload required:"
echo "   1. Download dari local: $archive_file"
echo "   2. Upload ke server: scp $archive_file $TARGET_USER@$TARGET_SERVER:/tmp/"
echo "   3. Extract: tar -xzf /tmp/$(basename $archive_file) -C \$DEST_DIR"
EOF
)
    
    remote_exec "$upload_cmd"
    
    echo "✅ Project ready for upload"
    echo "📁 Local archive: $archive_file"
}

# Fungsi untuk setup otomatis
auto_setup() {
    echo "⚙️  SETUP OTOMATIS DI SERVER..."
    
    local setup_cmd=$(cat << 'EOF'
#!/bin/bash

echo "🚀 Starting automatic setup..."

# 1. Update system
echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

# 2. Install dependencies
echo "📦 Installing dependencies..."
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# 3. Install Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# 4. Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 5. Install Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# 6. Install PostgreSQL
if ! systemctl is-active --quiet postgresql; then
    echo "🗄️ Installing PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
fi

# 7. Create project directory
PROJECT_DIR="/var/www/html/pesantren"
echo "📁 Creating project directory: $PROJECT_DIR"
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R $USER:$USER "$PROJECT_DIR"

echo "✅ Basic setup completed!"
EOF
)
    
    remote_exec "$setup_cmd"
}

# Fungsi untuk deploy
deploy_application() {
    echo "🚀 DEPLOYING APPLICATION..."
    
    local deploy_cmd=$(cat << 'EOF'
#!/bin/bash

PROJECT_DIR="/var/www/html/pesantren"
cd "$PROJECT_DIR"

echo "📂 Current directory: $(pwd)"
echo "📊 Directory contents:"
ls -la

# 1. Setup environment
echo "🔧 Setting up environment..."
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
    echo "⚠️  Please edit .env file with proper configuration"
fi

# 2. Start Docker services
echo "🐳 Starting Docker services..."
if [ -f "docker-compose.yml" ]; then
    docker-compose down 2>/dev/null
    docker-compose build --no-cache
    docker-compose up -d
    
    echo "⏳ Waiting for services to start..."
    sleep 10
    
    # Check services
    echo "🔍 Service status:"
    docker-compose ps
else
    echo "❌ docker-compose.yml not found"
    echo "📁 Available files:"
    find . -type f -name "*.yml" -o -name "*.yaml"
fi

# 3. Check backend
echo "🔧 Checking backend..."
if [ -d "backend" ]; then
    cd backend
    if [ -f "package.json" ]; then
        echo "📦 Installing backend dependencies..."
        npm install
        
        echo "🏗️ Building backend..."
        npm run build 2>/dev/null || echo "⚠️  Build might need configuration"
    fi
    cd ..
fi

echo "✅ Deployment completed!"
echo ""
echo "🌐 ACCESS INFORMATION:"
echo "   - Backend API: http://localhost:3000 (or server IP)"
echo "   - Web Interface: http://localhost"
echo "   - Database: localhost:5432"
echo ""
echo "📋 NEXT STEPS:"
echo "   1. Configure .env file"
echo "   2. Run database migrations"
echo "   3. Create admin user"
EOF
)
    
    remote_exec "$deploy_cmd"
}

# Fungsi untuk verifikasi
verify_installation() {
    echo "✅ VERIFYING INSTALLATION..."
    
    local verify_cmd=$(cat << 'EOF'
#!/bin/bash

echo "🔍 VERIFICATION REPORT"
echo "======================"

# Check Docker services
echo "1. DOCKER SERVICES:"
docker-compose ps 2>/dev/null || echo "   docker-compose not available"

# Check running containers
echo ""
echo "2. RUNNING CONTAINERS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -10

# Check backend
echo ""
echo "3. BACKEND STATUS:"
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "   ✅ Backend is responding"
elif curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "   ✅ Backend is running"
else
    echo "   ❌ Backend not responding"
fi

# Check database
echo ""
echo "4. DATABASE STATUS:"
if docker ps | grep -q postgres; then
    echo "   ✅ PostgreSQL container running"
    if docker exec $(docker ps -q --filter "name=postgres") pg_isready -U pesantren > /dev/null 2>&1; then
        echo "   ✅ Database connection OK"
    else
        echo "   ❌ Database connection failed"
    fi
else
    echo "   ⚠️  PostgreSQL not in Docker"
    if systemctl is-active --quiet postgresql; then
        echo "   ✅ PostgreSQL service running"
    fi
fi

# Check directories
echo ""
echo "5. PROJECT STRUCTURE:"
PROJECT_DIR="/var/www/html/pesantren"
if [ -d "$PROJECT_DIR" ]; then
    echo "   📁 Project directory exists"
    echo "   Contents:"
    find "$PROJECT_DIR" -maxdepth 2 -type d | sort | head -20 | while read -r dir; do
        echo "     - $(basename "$dir")"
    done
else
    echo "   ❌ Project directory not found"
fi

echo ""
echo "✅ Verification completed"
EOF
)
    
    remote_exec "$verify_cmd"
}

# Main menu
main_menu() {
    echo ""
    echo "🤖 AUTO MODULE ADDITION SYSTEM"
    echo "==============================="
    echo ""
    echo "Pilih opsi:"
    echo "1. 🔍 Deteksi sistem yang sudah ada"
    echo "2. ⚙️  Setup otomatis (install dependencies)"
    echo "3. 📤 Upload project ke server"
    echo "4. 🚀 Deploy aplikasi"
    echo "5. ✅ Verifikasi instalasi"
    echo "6. 🎯 Jalankan semua langkah"
    echo "7. 📋 Lihat manual instructions"
    echo "8. 🚪 Keluar"
    echo ""
    
    read -p "Pilihan [1-8]: " choice
    
    case $choice in
        1)
            detect_existing_system
            ;;
        2)
            auto_setup
            ;;
        3)
            copy_project_to_server
            ;;
        4)
            deploy_application
            ;;
        5)
            verify_installation
            ;;
        6)
            echo "🎯 MENJALANKAN SEMUA LANGKAH..."
            detect_existing_system
            echo ""
            auto_setup
            echo ""
            copy_project_to_server
            echo ""
            deploy_application
            echo ""
            verify_installation
            ;;
        7)
            show_manual_instructions
            ;;
        8)
            echo "👋 Sampai jumpa!"
            exit 0
            ;;
        *)
            echo "❌ Pilihan tidak valid"
            ;;
    esac
    
    # Loop kembali ke menu
    main_menu
}

# Fungsi untuk manual instructions
show_manual_instructions() {
    echo ""
    echo "📋 MANUAL INSTRUCTIONS"
    echo "======================"
    echo ""
    echo "Untuk admin server ($TARGET_SERVER):"
    echo ""
    echo "1. 🔐 LOGIN KE SERVER:"
    echo "   ssh $TARGET_USER@$TARGET_SERVER"
    echo "   Password: $TARGET_PASSWORD"
    echo ""
    echo "2. 📦 INSTALL DEPENDENCIES:"
    echo "   sudo apt update && sudo apt upgrade -y"
    echo "   sudo apt install -y docker.io docker-compose nodejs npm postgresql git"
    echo ""
    echo "3. 📁 BUAT DIREKTORI PROJECT:"
    echo "   sudo mkdir -p /var/www/html/pesantren"
    echo "   sudo chown -R $TARGET_USER:$TARGET_USER /var/www/html/pesantren"
    echo ""
    echo "4. 📤 UPLOAD PROJECT:"
    echo "   # Dari local machine:"
    echo "   scp -r pesantren-system/* $TARGET_USER@$TARGET_SERVER:/var/www/html/pesantren/"
    echo ""
    echo "5. 🚀 DEPLOY:"
    echo "   cd /var/www/html/pesantren"
    echo "   cp .env.example .env"
    echo "   # Edit .env file sesuai kebutuhan"
    echo "   docker-compose up -d"
    echo ""
    echo "6. ✅ VERIFIKASI:"
    echo "   docker-compose ps"
    echo "   curl http://localhost:3000/health"
    echo ""
    echo "7. 🔧 TROUBLESHOOTING:"
    echo "   - Cek logs: docker-compose logs -f"
    echo "   - Restart: docker-compose restart"
    echo "   - Rebuild: docker-compose up -d --build"
    echo ""
    echo "📞 Untuk bantuan teknis, gunakan script otomatis atau hubungi support."
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Jangan jalankan sebagai root. Gunakan user biasa."
    exit 1
fi

# Check connectivity
echo "🌐 Checking connection to $TARGET_SERVER..."
if ping -c 1 -W 2 $TARGET_SERVER &> /dev/null; then
    echo "✅ Server reachable"
else
    echo "❌ Server tidak bisa diakses"
    echo "⚠️  Pastikan server $TARGET_SERVER aktif dan bisa diakses dari network ini"
fi

# Start main menu
main_menu