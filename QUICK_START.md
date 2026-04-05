# 🚀 Quick Start Guide - Sistem Informasi Pondok Pesantren

## 📋 Prerequisites

### Server Requirements
- **OS**: Ubuntu 22.04/24.04 LTS or Debian 11/12
- **CPU**: 4+ cores
- **RAM**: 8GB+ (16GB recommended)
- **Storage**: 100GB+ SSD
- **Network**: Stable internet connection

### Software Requirements
- Docker & Docker Compose
- Node.js 18+
- PHP 8.2+
- PostgreSQL 15+
- Redis 7+

## ⚡ Quick Installation

### Option 1: Automated Setup (Recommended)
```bash
# Download setup script
wget https://raw.githubusercontent.com/your-repo/pesantren-system/main/scripts/setup-server.sh

# Make executable
chmod +x setup-server.sh

# Run as root
sudo ./setup-server.sh
```

### Option 2: Manual Setup
```bash
# 1. Clone repository
git clone https://github.com/your-repo/pesantren-system.git
cd pesantren-system

# 2. Copy environment file
cp .env.example .env

# 3. Edit configuration
nano .env

# 4. Start services
cd deploy
docker-compose up -d

# 5. Initialize database
docker-compose exec postgres psql -U pesantren -d pesantren_db -f /docker-entrypoint-initdb.d/init.sql
```

## 🎯 First-Time Setup

### 1. Server Configuration
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install -y docker-compose-plugin
```

### 2. Project Setup
```bash
# Create project directory
sudo mkdir -p /opt/pesantren-system
sudo chown -R $USER:$USER /opt/pesantren-system

# Copy project files
cp -r . /opt/pesantren-system/
cd /opt/pesantren-system
```

### 3. Environment Configuration
```bash
# Copy environment file
cp .env.example .env

# Edit with your configuration
nano .env

# Important settings to update:
# - DB_PASSWORD
# - JWT_SECRET
# - MAIL_* settings
# - Payment gateway keys
```

### 4. Start Services
```bash
# Navigate to deploy directory
cd deploy

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## 🌐 Access Services

### Development URLs
- **Web Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **Admin Panel**: http://localhost:8000
- **pgAdmin**: http://localhost:5050
- **API Documentation**: http://localhost:3000/api/docs

### Default Credentials
- **pgAdmin**: admin@pesantren.local / PgAdmin2026!
- **Database**: pesantren / Pesantren2026!
- **Redis**: RedisPesantren2026!

## 🔧 Development Setup

### Backend Development (NestJS)
```bash
cd backend

# Install dependencies
npm install

# Development mode
npm run start:dev

# Build for production
npm run build

# Run tests
npm test
```

### Admin Panel Development (Laravel)
```bash
cd admin

# Install dependencies
composer install

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Development server
php artisan serve
```

### Web Frontend Development (Next.js)
```bash
cd web

# Install dependencies
npm install

# Development mode
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## 📊 Database Management

### Common Database Operations
```bash
# Access PostgreSQL
docker-compose exec postgres psql -U pesantren -d pesantren_db

# Run migrations
docker-compose exec backend npm run migration:run

# Create backup
docker-compose exec postgres pg_dump -U pesantren pesantren_db > backup.sql

# Restore backup
docker-compose exec postgres psql -U pesantren -d pesantren_db < backup.sql
```

### Seed Initial Data
```bash
# Run seeders
docker-compose exec backend npm run seed:run

# Create admin user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pesantren.local",
    "password": "AdminPesantren2026!",
    "name": "Administrator",
    "role": "super_admin"
  }'
```

## 🚀 Deployment to Production

### 1. Production Preparation
```bash
# Update environment for production
cp .env.example .env.production
nano .env.production

# Build production images
docker-compose -f docker-compose.prod.yml build

# Push to registry (if using)
docker-compose -f docker-compose.prod.yml push
```

### 2. Server Deployment
```bash
# Copy production files to server
scp -r deploy/ user@server:/opt/pesantren-system/

# SSH to server
ssh user@server

# Start production services
cd /opt/pesantren-system/deploy
docker-compose -f docker-compose.prod.yml up -d
```

### 3. SSL Certificate Setup
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal setup
sudo certbot renew --dry-run
```

## 📱 Mobile App Development

### Flutter Setup
```bash
# Install Flutter SDK
sudo snap install flutter --classic

# Verify installation
flutter doctor

# Setup for Android/iOS
flutter config --android-sdk /path/to/android/sdk
flutter config --ios-signing-cert "Apple Development"
```

### Build Mobile Apps
```bash
cd mobile

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK for Android
flutter build apk --release

# Build IPA for iOS
flutter build ios --release
```

## 🔐 Security Checklist

### Initial Security Setup
- [ ] Change all default passwords
- [ ] Setup SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Enable automatic security updates
- [ ] Setup backup system
- [ ] Configure monitoring alerts

### Regular Security Tasks
- [ ] Weekly security updates
- [ ] Monthly vulnerability scans
- [ ] Quarterly security audits
- [ ] Annual penetration testing

## 📈 Monitoring & Maintenance

### Daily Checks
```bash
# Check service status
docker-compose ps

# Check logs for errors
docker-compose logs --tail=100

# Check disk space
df -h

# Check memory usage
free -h
```

### Monitoring Tools
- **Grafana**: http://localhost:3002 (admin/GrafanaPesantren2026!)
- **Prometheus**: http://localhost:9090
- **Logs**: /opt/pesantren-system/logs/

### Backup System
```bash
# Manual backup
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh backup_file.tar.gz

# Check backup schedule
crontab -l
```

## 🆘 Troubleshooting

### Common Issues

#### 1. Docker Services Not Starting
```bash
# Check Docker service
sudo systemctl status docker

# Check container logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

#### 2. Database Connection Issues
```bash
# Check PostgreSQL service
docker-compose exec postgres pg_isready

# Test connection
docker-compose exec postgres psql -U pesantren -d pesantren_db -c "SELECT 1;"

# Reset database (development only)
docker-compose down -v
docker-compose up -d
```

#### 3. Port Conflicts
```bash
# Check used ports
sudo netstat -tulpn | grep LISTEN

# Change port in docker-compose.yml
# Update: ports: "NEW_PORT:CONTAINER_PORT"
```

### Getting Help
- **Documentation**: /opt/pesantren-system/docs/
- **Issue Tracker**: GitHub Issues
- **Support Chat**: WhatsApp +6282115156464
- **Community**: Discord/Telegram group

## 📚 Next Steps

### After Installation
1. **Configure System Settings**
   - Update organization information
   - Configure academic year
   - Setup payment methods
   - Configure notification templates

2. **User Training**
   - Admin training session
   - Teacher orientation
   - Parent portal demonstration
   - Student mobile app tutorial

3. **Data Migration**
   - Import existing student data
   - Migrate financial records
   - Transfer academic history
   - Import library inventory

### Development Roadmap
- **Week 1-2**: Core authentication & user management
- **Week 3-4**: Student & academic management
- **Week 5-6**: Finance & payment integration
- **Week 7-8**: Mobile app development
- **Week 9-10**: Advanced features & optimization

## 📞 Support Contacts

### Technical Support
- **Email**: tech@pesantren-system.local
- **WhatsApp**: +6282115156464
- **Telegram**: @pesantren_support
- **Office Hours**: 08:00-17:00 WIB (Mon-Fri)

### Emergency Contacts
- **System Outage**: +6282115156464 (24/7)
- **Data Emergency**: +6282115156464
- **Security Incident**: security@pesantren-system.local

---
**Quick Start Version**: 1.0.0  
**Last Updated**: 2026-04-04  
**System Status**: Ready for Development