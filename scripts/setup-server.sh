#!/bin/bash

# 🕌 Setup Script for Pondok Pesantren Management System
# Version: 1.0.0
# Author: OpenClaw Assistant
# Date: 2026-04-04

set -e  # Exit on error

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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check server OS
check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    log_info "Detected OS: $OS $VER"
    
    if [[ "$OS" != "Ubuntu" ]] && [[ ! "$OS" =~ "Debian" ]]; then
        log_warning "This script is optimized for Ubuntu/Debian. Other distros may require adjustments."
    fi
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    log_success "System updated successfully"
}

# Install Docker and Docker Compose
install_docker() {
    log_info "Installing Docker..."
    
    # Remove old versions
    apt-get remove -y docker docker-engine docker.io containerd runc
    
    # Install dependencies
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Add current user to docker group
    usermod -aG docker $SUDO_USER
    
    log_success "Docker installed successfully"
}

# Install Node.js
install_nodejs() {
    log_info "Installing Node.js 18..."
    
    # Remove existing Node.js
    apt-get remove -y nodejs npm
    
    # Install Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    
    # Install global npm packages
    npm install -g npm@latest
    npm install -g @nestjs/cli
    
    log_success "Node.js installed successfully"
}

# Install PHP and Composer
install_php() {
    log_info "Installing PHP 8.2 and Composer..."
    
    # Add PHP repository
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:ondrej/php
    apt-get update -y
    
    # Install PHP 8.2 with extensions
    apt-get install -y \
        php8.2 \
        php8.2-fpm \
        php8.2-common \
        php8.2-mysql \
        php8.2-pgsql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-bcmath \
        php8.2-redis \
        php8.2-intl
    
    # Install Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
    log_success "PHP and Composer installed successfully"
}

# Install PostgreSQL
install_postgresql() {
    log_info "Installing PostgreSQL..."
    
    # Install PostgreSQL
    apt-get install -y postgresql postgresql-contrib
    
    # Start and enable PostgreSQL
    systemctl start postgresql
    systemctl enable postgresql
    
    log_success "PostgreSQL installed successfully"
}

# Install Redis
install_redis() {
    log_info "Installing Redis..."
    
    apt-get install -y redis-server
    
    # Configure Redis
    sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/g' /etc/redis/redis.conf
    echo "requirepass RedisPesantren2026!" >> /etc/redis/redis.conf
    
    systemctl restart redis-server
    systemctl enable redis-server
    
    log_success "Redis installed successfully"
}

# Install Nginx
install_nginx() {
    log_info "Installing Nginx..."
    
    apt-get install -y nginx
    
    # Configure firewall
    ufw allow 'Nginx Full'
    ufw allow ssh
    ufw --force enable
    
    systemctl start nginx
    systemctl enable nginx
    
    log_success "Nginx installed successfully"
}

# Install monitoring tools
install_monitoring() {
    log_info "Installing monitoring tools..."
    
    apt-get install -y \
        htop \
        net-tools \
        iftop \
        nmon \
        sysstat \
        prometheus-node-exporter
    
    log_success "Monitoring tools installed successfully"
}

# Setup project directory
setup_project() {
    log_info "Setting up project directory..."
    
    PROJECT_DIR="/opt/pesantren-system"
    
    # Create project directory
    mkdir -p $PROJECT_DIR
    chown -R $SUDO_USER:$SUDO_USER $PROJECT_DIR
    
    # Create necessary subdirectories
    mkdir -p $PROJECT_DIR/{backend,admin,web,mobile,deploy,database,logs,uploads,docs,scripts}
    
    # Set permissions
    chmod 755 $PROJECT_DIR
    chmod -R 755 $PROJECT_DIR/logs
    chmod -R 755 $PROJECT_DIR/uploads
    
    log_success "Project directory created at $PROJECT_DIR"
}

# Generate SSL certificates
generate_ssl() {
    log_info "Generating SSL certificates..."
    
    SSL_DIR="/etc/nginx/ssl"
    mkdir -p $SSL_DIR
    
    # Generate self-signed certificate (for development)
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $SSL_DIR/pesantren.key \
        -out $SSL_DIR/pesantren.crt \
        -subj "/C=ID/ST=Java/L=Bandung/O=Pondok Pesantren/CN=pesantren.local"
    
    chmod 600 $SSL_DIR/pesantren.key
    
    log_success "SSL certificates generated successfully"
}

# Configure firewall
configure_firewall() {
    log_info "Configuring firewall..."
    
    # Allow necessary ports
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    ufw allow 3000/tcp  # Backend API
    ufw allow 3001/tcp  # Web frontend
    ufw allow 8000/tcp  # Admin panel
    ufw allow 5432/tcp  # PostgreSQL
    ufw allow 6379/tcp  # Redis
    ufw allow 5050/tcp  # pgAdmin
    
    log_success "Firewall configured successfully"
}

# Create systemd service
create_service() {
    log_info "Creating systemd service..."
    
    SERVICE_FILE="/etc/systemd/system/pesantren.service"
    
    cat > $SERVICE_FILE << EOF
[Unit]
Description=Pondok Pesantren Management System
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/pesantren-system/deploy
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=$SUDO_USER
Group=$SUDO_USER

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable pesantren.service
    
    log_success "Systemd service created successfully"
}

# Setup backup script
setup_backup() {
    log_info "Setting up backup system..."
    
    BACKUP_SCRIPT="/opt/pesantren-system/scripts/backup.sh"
    
    cat > $BACKUP_SCRIPT << 'EOF'
#!/bin/bash

# Backup script for Pondok Pesantren System
BACKUP_DIR="/opt/pesantren-backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup PostgreSQL database
docker exec pesantren_postgres pg_dump -U pesantren pesantren_db > $BACKUP_DIR/db_backup_$DATE.sql
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Backup uploads directory
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz -C /opt/pesantren-system uploads

# Backup configuration files
tar -czf $BACKUP_DIR/config_backup_$DATE.tar.gz \
    /opt/pesantren-system/deploy \
    /etc/nginx/sites-available/pesantren.conf

# Remove old backups
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $BACKUP_DIR"
EOF
    
    chmod +x $BACKUP_SCRIPT
    
    # Add to crontab for daily backups at 2 AM
    (crontab -l 2>/dev/null; echo "0 2 * * * /opt/pesantren-system/scripts/backup.sh") | crontab -
    
    log_success "Backup system configured successfully"
}

# Display setup summary
display_summary() {
    log_info "=========================================="
    log_info "SETUP COMPLETED SUCCESSFULLY!"
    log_info "=========================================="
    echo ""
    log_info "Services Installed:"
    echo "  • Docker & Docker Compose"
    echo "  • Node.js 18 + NestJS CLI"
    echo "  • PHP 8.2 + Composer"
    echo "  • PostgreSQL 15"
    echo "  • Redis"
    echo "  • Nginx"
    echo "  • Monitoring tools"
    echo ""
    log_info "Project Structure:"
    echo "  • Project directory: /opt/pesantren-system"
    echo "  • Backend API: http://localhost:3000"
    echo "  • Admin Panel: http://localhost:8000"
    echo "  • Web Frontend: http://localhost:3001"
    echo "  • pgAdmin: http://localhost:5050"
    echo ""
    log_info "Database Credentials:"
    echo "  • Database: pesantren_db"
    echo "  • Username: pesantren"
    echo "  • Password: Pesantren2026!"
    echo ""
    log_info "Redis Credentials:"
    echo "  • Password: RedisPesantren2026!"
    echo ""
    log_info "Next Steps:"
    echo "  1. Copy project files to /opt/pesantren-system"
    echo "  2. Run: cd /opt/pesantren-system/deploy && docker-compose up -d"
    echo "  3. Access the system at http://localhost"
    echo ""
    log_info "Backup System:"
    echo "  • Daily backups at 2 AM"
    echo "  • Backup directory: /opt/pesantren-backups"
    echo "  • Retention: 7 days"
    echo ""
    log_info "Monitoring:"
    echo "  • System monitoring: htop, nmon"
    echo "  • Logs: /opt/pesantren-system/logs/"
    echo "  • Service: systemctl status pesantren"
    echo ""
    log_info "Support:"
    echo "  • WhatsApp: +6282115156464"
    echo "  • Documentation: /opt/pesantren-system/docs/"
    echo ""
    log_info "=========================================="
}

# Main setup function
main() {
    log_info "Starting Pondok Pesantren System Setup..."
    log_info "Date: $(date)"
    log_info "User: $SUDO_USER"
    echo ""
    
    # Run setup steps
    check_root
    check_os
    update_system
    install_docker
    install_nodejs
    install_php
    install_postgresql
    install_redis
    install_nginx
    install_monitoring
    setup_project
    generate_ssl
    configure_firewall
    create_service
    setup_backup
    
    echo ""
    display_summary
    
    log_success "Setup completed successfully!"
    log_info "Please logout and login again for Docker group changes to take effect."
}

# Run main function
main "$@"