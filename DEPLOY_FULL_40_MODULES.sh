#!/bin/bash

# ============================================
# DEPLOY_FULL_40_MODULES.sh
# Script deployment lengkap untuk 40 modul sistem pesantren
# Dijalankan di server 192.168.55.4 sebagai user sisfo
# ============================================

set -e  # Exit on error
set -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo -e "${GREEN}"
echo "=========================================="
echo "🚀 DEPLOYMENT 40 MODUL SISTEM PESANTREN"
echo "=========================================="
echo -e "${NC}"
echo "Server: $(hostname)"
echo "User: $(whoami)"
echo "Date: $(date)"
echo ""

# ============================================
# STEP 1: CHECK PREREQUISITES
# ============================================
log_info "Step 1: Checking prerequisites..."

# Check if running as root or with sudo
if [ "$EUID" -eq 0 ]; then
    log_warning "Running as root. It's better to run as regular user with sudo."
fi

# Check disk space
DISK_SPACE=$(df -h / | awk 'NR==2 {print $4}')
log_info "Available disk space: $DISK_SPACE"

# Check memory
MEMORY=$(free -h | awk 'NR==2 {print $4}')
log_info "Available memory: $MEMORY"

# ============================================
# STEP 2: INSTALL DEPENDENCIES
# ============================================
log_info "Step 2: Installing dependencies..."

# Update package list
sudo apt update

# Install Docker
if ! command -v docker &> /dev/null; then
    log_info "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    log_success "Docker installed successfully"
else
    log_info "Docker already installed: $(docker --version)"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    log_info "Installing Docker Compose..."
    sudo apt install -y docker-compose
    log_success "Docker Compose installed successfully"
else
    log_info "Docker Compose already installed: $(docker-compose --version)"
fi

# Install PostgreSQL client (optional but useful)
if ! command -v psql &> /dev/null; then
    log_info "Installing PostgreSQL client..."
    sudo apt install -y postgresql-client
    log_success "PostgreSQL client installed"
fi

# Install curl if not exists
if ! command -v curl &> /dev/null; then
    sudo apt install -y curl
fi

# ============================================
# STEP 3: SETUP PROJECT DIRECTORY
# ============================================
log_info "Step 3: Setting up project directory..."

PROJECT_DIR="/var/www/html/pesantren"
BACKUP_DIR="/var/backups/pesantren-$(date +%Y%m%d-%H%M%S)"

# Create backup of existing installation if exists
if [ -d "$PROJECT_DIR" ]; then
    log_warning "Existing installation found at $PROJECT_DIR"
    log_info "Creating backup to $BACKUP_DIR..."
    sudo mkdir -p "$(dirname "$BACKUP_DIR")"
    sudo cp -r "$PROJECT_DIR" "$BACKUP_DIR"
    log_success "Backup created: $BACKUP_DIR"
fi

# Create project directory
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R $USER:$USER "$PROJECT_DIR"
cd "$PROJECT_DIR"

log_success "Project directory ready: $PROJECT_DIR"

# ============================================
# STEP 4: CREATE DOCKER COMPOSE CONFIGURATION
# ============================================
log_info "Step 4: Creating Docker Compose configuration..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: pesantren-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: pesantren_db
      POSTGRES_USER: pesantren
      POSTGRES_PASSWORD: Pesantren2026!
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U pesantren -d pesantren_db"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - pesantren-network

  # Backend API Service
  backend:
    image: node:18-alpine
    container_name: pesantren-backend
    restart: unless-stopped
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: sh -c "npm install && npm start"
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: pesantren_db
      DB_USER: pesantren
      DB_PASS: Pesantren2026!
      JWT_SECRET: change-this-to-a-secure-random-string-in-production
      PORT: 3000
    networks:
      - pesantren-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: pesantren-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/sites:/etc/nginx/sites-enabled
      - ./nginx/ssl:/etc/nginx/ssl
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - backend
    networks:
      - pesantren-network

  # Redis Cache (optional)
  redis:
    image: redis:7-alpine
    container_name: pesantren-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    networks:
      - pesantren-network

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  pesantren-network:
    driver: bridge
EOF

log_success "Docker Compose configuration created"

# ============================================
# STEP 5: CREATE NGINX CONFIGURATION
# ============================================
log_info "Step 5: Creating Nginx configuration..."

mkdir -p nginx/sites nginx/ssl logs/nginx

cat > nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/javascript application/xml+rss 
               application/json;

    # Include site configurations
    include /etc/nginx/sites-enabled/*;
}
EOF

cat > nginx/sites/pesantren.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # API endpoints
    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }
    
    # Static files (future frontend)
    location / {
        try_files $uri $uri/ @backend;
    }
    
    location @backend {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

log_success "Nginx configuration created"

# ============================================
# STEP 6: CREATE DATABASE SCHEMA
# ============================================
log_info "Step 6: Creating database schema..."

mkdir -p database

# Create main schema file
cat > database/01_main_schema.sql << 'EOF'
-- ============================================
-- PESANTREN SYSTEM DATABASE SCHEMA
-- 40 Modules - Multi Lembaga Architecture
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. CORE TABLES
-- ============================================

-- Lembaga (MTs, SMP, MA, Tahfidz)
CREATE TABLE lembaga (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    kode_lembaga VARCHAR(20) UNIQUE NOT NULL,
    nama_lembaga VARCHAR(100) NOT NULL,
    jenis_lembaga VARCHAR(20) NOT NULL CHECK (jenis_lembaga IN ('MTS', 'SMP', 'MA', 'TAHFIDZ')),
    alamat TEXT,
    telepon VARCHAR(20),
    email VARCHAR(255),
    kepala_lembaga VARCHAR(100),
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'NONAKTIF')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users with multi-role support
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER' CHECK (role IN ('SUPERADMIN', 'ADMIN', 'USTADZ', 'GURU', 'STAFF', 'WALI', 'SANTRI')),
    lembaga_id INTEGER REFERENCES lembaga(id),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. SANTRI MANAGEMENT
-- ============================================

CREATE TABLE santri (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(20),
    nama_lengkap VARCHAR(100) NOT NULL,
    nama_panggilan VARCHAR(50),
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('LAKI-LAKI', 'PEREMPUAN')),
    agama VARCHAR(20) DEFAULT 'ISLAM',
    alamat TEXT,
    telepon VARCHAR(20),
    foto_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'ALUMNI', 'KELUAR', 'MUTASI')),
    tanggal_masuk DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Santri can belong to multiple lembaga
CREATE TABLE santri_lembaga (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    lembaga_id INTEGER REFERENCES lembaga(id) ON DELETE CASCADE,
    tahun_ajaran VARCHAR(9) NOT NULL, -- Format: 2024/2025
    kelas VARCHAR(20),
    status VARCHAR(20) DEFAULT 'AKTIF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, lembaga_id, tahun_ajaran)
);

-- ============================================
-- 3. TAHFIDZ MODULE (SPECIAL)
-- ============================================

CREATE TABLE tahfidz_program (
    id SERIAL PRIMARY KEY,
    nama_program VARCHAR(100) NOT NULL,
    target_juz INTEGER CHECK (target_juz BETWEEN 1 AND 30),
    durasi_bulan INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE santri_tahfidz (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) UNIQUE,
    program_id INTEGER REFERENCES tahfidz_program(id),
    ustadz_pembimbing INTEGER REFERENCES users(id),
    tanggal_mulai DATE,
    target_selesai DATE,
    status VARCHAR(20) DEFAULT 'BERJALAN' CHECK (status IN ('BERJALAN', 'SELESAI', 'BERHENTI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tahfidz_progress (
    id SERIAL PRIMARY KEY,
    santri_tahfidz_id INTEGER REFERENCES santri_tahfidz(id) ON DELETE CASCADE,
    juz INTEGER NOT NULL CHECK (juz BETWEEN 1 AND 30),
    halaman_mulai INTEGER CHECK (halaman_mulai BETWEEN 1 AND 604),
    halaman_selesai INTEGER CHECK (halaman_selesai BETWEEN 1 AND 604),
    tanggal_setoran DATE NOT NULL,
    nilai_tajwid INTEGER CHECK (nilai_tajwid BETWEEN 1 AND 100),
    nilai_kelancaran INTEGER CHECK (nilai_kelancaran BETWEEN 1 AND 100),
    catatan TEXT,
    disetorkan_ke INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 4. ACADEMIC MODULES
-- ============================================

CREATE TABLE tahun_ajaran (
    id SERIAL PRIMARY KEY,
    kode_tahun VARCHAR(9) UNIQUE NOT NULL, -- 2024/2025
    nama_tahun VARCHAR(50) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'SELESAI', 'RENCANA')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mata_pelajaran (
    id SERIAL PRIMARY KEY,
    kode_mapel VARCHAR(20) UNIQUE NOT NULL,
    nama_mapel VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('FORMAL', 'DINIAH', 'UMUM')),
    lembaga_id INTEGER REFERENCES lembaga(id),
    kkm INTEGER DEFAULT 75,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial data
INSERT INTO lembaga (kode_lembaga, nama_lembaga, jenis_lembaga