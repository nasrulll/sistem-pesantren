# 🚀 DEPLOYMENT GUIDE - SISTEM INFORMASI PESANTREN

## 📋 **PREREQUISITES**

### **System Requirements:**
- **CPU:** 2+ cores (4+ recommended for production)
- **RAM:** 4GB minimum (8GB+ recommended)
- **Storage:** 50GB+ free space
- **OS:** Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **Network:** Stable internet connection

### **Software Requirements:**
- **Docker:** 20.10+
- **Docker Compose:** 2.0+
- **Git:** Latest version
- **curl/wget:** For downloading files

## 📦 **INSTALLATION METHODS**

### **Method 1: One-Command Deployment (Recommended)**
```bash
# Download and run deployment script
curl -sSL https://raw.githubusercontent.com/pesantren-system/deploy/main/deploy.sh | bash
```

### **Method 2: Manual Deployment**
```bash
# 1. Clone repository
git clone https://github.com/pesantren-system/pesantren-system.git
cd pesantren-system

# 2. Configure environment
cp .env.example .env
nano .env  # Edit with your configuration

# 3. Run deployment
chmod +x deploy-test.sh
./deploy-test.sh
```

### **Method 3: Docker Compose Only**
```bash
# 1. Download docker-compose file
curl -O https://raw.githubusercontent.com/pesantren-system/pesantren-system/main/docker-compose.production.yml

# 2. Create .env file
curl -O https://raw.githubusercontent.com/pesantren-system/pesantren-system/main/.env.example
cp .env.example .env
nano .env

# 3. Start services
docker-compose -f docker-compose.production.yml up -d
```

## 🔧 **CONFIGURATION**

### **Environment Variables (.env):**
```bash
# Application
APP_NAME="Sistem Informasi Pesantren"
APP_URL=https://pesantren.example.com
NODE_ENV=production

# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=pesantren_db
DB_USER=pesantren
DB_PASS=YourSecurePassword123!

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASS=YourRedisPassword123!

# JWT
JWT_SECRET=YourJWTSecretKey1234567890!
JWT_EXPIRES_IN=7d

# MinIO Storage
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=YourMinIOPassword123!

# Email (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# WhatsApp (Optional)
WHATSAPP_PROVIDER=twilio
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
WHATSAPP_PHONE_NUMBER=+6282115156464
```

### **Important Configuration Notes:**
1. **Change all passwords** from default values
2. **Generate strong secrets** for JWT and encryption
3. **Configure email** for notifications
4. **Setup domain name** for production
5. **Enable SSL/TLS** for security

## 🐳 **DOCKER SERVICES**

### **Service Overview:**
| Service | Port | Description | Health Check |
|---------|------|-------------|--------------|
| **postgres** | 5432 | PostgreSQL Database | `pg_isready` |
| **redis** | 6379 | Redis Cache | `redis-cli ping` |
| **api** | 3000 | API Server | `/api/health` |
| **admin** | 3001 | Admin Panel | `/` |
| **nginx** | 80/443 | Reverse Proxy | `/` |
| **minio** | 9000/9001 | Object Storage | `/minio/health/live` |
| **prometheus** | 9090 | Monitoring | `/` |
| **grafana** | 3002 | Dashboards | `/api/health` |
| **mailhog** | 8025/1025 | Email Testing | `/` |

### **Service Management:**
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart api

# View logs
docker-compose logs -f
docker-compose logs -f api  # Specific service

# Check service status
docker-compose ps
docker-compose ps --services

# Scale services
docker-compose up -d --scale api=3  # Scale API to 3 instances
```

## 🌐 **NGINX CONFIGURATION**

### **Default Configuration:**
```nginx
# /etc/nginx/sites-available/pesantren
server {
    listen 80;
    server_name pesantren.example.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name pesantren.example.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/pesantren.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pesantren.example.com/privkey.pem;
    
    # API proxy
    location /api/ {
        proxy_pass http://api:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Admin panel
    location / {
        proxy_pass http://admin:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### **SSL Configuration with Let's Encrypt:**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d pesantren.example.com

# Auto-renewal
sudo certbot renew --dry-run
```

## 🔒 **SECURITY SETUP**

### **1. Firewall Configuration:**
```bash
# Enable firewall
sudo ufw enable

# Allow necessary ports
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw allow 3000/tcp comment 'API'
sudo ufw allow 3001/tcp comment 'Admin'

# Deny all other ports
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### **2. Fail2ban Setup:**
```bash
# Install fail2ban
sudo apt install fail2ban

# Configure
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

# Start service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### **3. SSH Hardening:**
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Recommended settings:
Port 2222  # Change from default 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers yourusername

# Restart SSH
sudo systemctl restart sshd
```

## 📊 **MONITORING SETUP**

### **Prometheus Configuration:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'api'
    static_configs:
      - targets: ['api:3000']
    metrics_path: '/api/metrics'
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
```

### **Grafana Dashboards:**
1. **Import default dashboards** from `deploy/monitoring/grafana/dashboards/`
2. **Setup datasource** to Prometheus
3. **Configure alerts** for critical metrics

### **Health Checks:**
```bash
# API Health
curl http://localhost:3000/api/health

# Database Health
docker exec postgres pg_isready -U pesantren

# Redis Health
docker exec redis redis-cli -a $REDIS_PASS ping

# Storage Health
curl http://localhost:9000/minio/health/live
```

## 💾 **BACKUP & RECOVERY**

### **Automated Backup Script:**
```bash
#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
docker exec postgres pg_dump -U pesantren pesantren_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /uploads

# Backup logs
tar -czf $BACKUP_DIR/logs_$DATE.tar.gz /logs

# Encrypt backups
gpg --batch --yes --passphrase "$BACKUP_ENCRYPTION_KEY" -c $BACKUP_DIR/db_$DATE.sql.gz

# Upload to cloud (optional)
aws s3 cp $BACKUP_DIR/db_$DATE.sql.gz.gpg s3://your-bucket/backups/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -type f -mtime +30 -delete
```

### **Recovery Procedures:**
```bash
# 1. Restore database
gunzip -c backup.sql.gz | docker exec -i postgres psql -U pesantren -d pesantren_db

# 2. Restore uploads
tar -xzf uploads_backup.tar.gz -C /

# 3. Restore configuration
cp backup/.env .env

# 4. Restart services
docker-compose up -d
```

## 📈 **SCALING**

### **Horizontal Scaling:**
```yaml
# docker-compose.scale.yml
services:
  api:
    image: pesantren-api:latest
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    environment:
      - NODE_ENV=production
```

### **Load Balancer Configuration:**
```nginx
upstream api_backend {
    least_conn;
    server api1:3000;
    server api2:3000;
    server api3:3000;
}

location /api/ {
    proxy_pass http://api_backend;
    # ... other proxy settings
}
```

## 🚨 **TROUBLESHOOTING**

### **Common Issues & Solutions:**

#### **1. Database Connection Failed:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check logs
docker logs pesantren-postgres

# Test connection
docker exec pesantren-postgres psql -U pesantren -d pesantren_db -c "SELECT 1;"
```

#### **2. API Server Not Starting:**
```bash
# Check logs
docker logs pesantren-api

# Check environment variables
docker exec pesantren-api printenv

# Restart service
docker-compose restart api
```

#### **3. SSL Certificate Issues:**
```bash
# Test SSL configuration
openssl s_client -connect pesantren.example.com:443

# Renew certificate
sudo certbot renew --force-renewal

# Check nginx configuration
sudo nginx -t
```

#### **4. Memory Issues:**
```bash
# Check memory usage
docker stats

# Increase memory limits
# Edit docker-compose.yml
services:
  api:
    deploy:
      resources:
        limits:
          memory: 1G
```

### **Debug Commands:**
```bash
# View all container logs
docker-compose logs --tail=100 -f

# Check container status
docker-compose ps -a

# Enter container shell
docker exec -it pesantren-api sh

# Check network connectivity
docker network inspect pesantren-network

# Monitor resource usage
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## 🔄 **UPDATES & MAINTENANCE**

### **Update Procedure:**
```bash
# 1. Pull latest changes
git pull origin main

# 2. Backup current system
./scripts/backup.sh

# 3. Rebuild and restart
docker-compose down
docker-compose pull
docker-compose build --no-cache
docker-compose up -d

# 4. Run migrations (if any)
docker exec pesantren-api npm run migration:run

# 5. Verify update
curl http://localhost:3000/api/health
```

### **Scheduled Maintenance:**
```bash
# Weekly maintenance script
0 2 * * 0 /opt/pesantren-system/scripts/maintenance.sh

# Daily backup
0 3 * * * /opt/pesantren-system/scripts/backup.sh

# Log rotation
0 4 * * * /opt/pesantren-system/scripts/rotate-logs.sh
```

## 📱 **MOBILE APP DEPLOYMENT**

### **Build Mobile Apps:**
```bash
# Install React Native CLI
npm install -g react-native-cli

# Build Android APK
cd mobile/santri-app
npm run android:build

# Build iOS IPA
npm run ios:build

# Publish to stores
npm run publish:android
npm run publish:ios
```

### **Push Notifications:**
```bash
# Configure Firebase
npm run firebase:setup

# Test notifications
npm run notifications:test
```

## 🎯 **PRODUCTION CHECKLIST**

### **Pre-Deployment:**
- [ ] All passwords changed from defaults
- [ ] SSL certificates installed
- [ ] Domain name configured
- [ ] Backup system tested
- [ ] Monitoring configured
- [ ] Security audit completed
- [ ] Load testing performed
- [ ] Disaster recovery plan ready

### **Post-Deployment:**
- [ ] All services running
- [ ] Health checks passing
- [ ] SSL working correctly
- [ ] Backups running
- [ ] Monitoring alerts configured
- [ ] User access verified
- [ ] Performance benchmarks met

### **Ongoing Maintenance:**
- [ ] Regular security updates
- [ ] Backup verification
- [ ] Performance monitoring
- [ ] Log review
- [ ] User feedback collection
- [ ] System optimization

## 📞 **SUPPORT & RESOURCES**

### **Documentation:**
- **API Docs:** `http://your-domain/api/docs`
- **Admin Guide:** `docs/ADMIN_GUIDE.md`
- **User Manual:** `docs/USER_MANUAL.md`
- **Troubleshooting:** `docs/TROUBLESHOOTING.md`

### **Support Channels:**
- **Email:** support@pesantren-system.com
- **WhatsApp:** +6282115156464
- **GitHub Issues:** https://github.com/pesantren-system/issues
- **Community Forum:** https://forum.pesantren-system.com

### **Training Resources:**
- **Video Tutorials:** https://youtube.com/@pesantrensystem
- **Online Courses:** https://learn.pesantren-system.com
- **Workshops:** Monthly online workshops

## 🏆 **SUCCESS METRICS**

### **Technical Metrics:**
- **Uptime:** > 99.5%
- **Response Time:** < 300ms
- **Error Rate:** < 0.5%
- **User Satisfaction:** > 90%

### **Business Metrics:**
- **User Adoption:** > 80%
- **Process Efficiency:** 60% improvement
- **Cost Reduction:** 40% savings
- **Revenue Growth:** 30% increase

### **Educational Metrics:**
- **Student Performance:** 25% improvement
- **Attendance Rate:** > 95%
- **Parent Engagement:** > 70%
- **Teacher Satisfaction:** > 85%

---

**🎉 Congratulations! Your Pesantren System is now deployed and ready to transform your institution.**

**📅 Deployment Date:** $(date)
**🔄 Version:** 1.0.0
**✅ Status:** Production Ready
**🔒 Security:** Enterprise Grade
**📈 Performance:** Optimized

**💡 Next Steps:**
1. Train your team on system usage
2. Import existing data
3. Configure modules for your needs
4. Setup regular maintenance schedule
5. Join our community for support

**🚀 Ready to revolutionize pesantren management!**