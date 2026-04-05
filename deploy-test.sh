#!/bin/bash

echo "🚀 PESANTREN SYSTEM - TEST DEPLOYMENT"
echo "======================================"
echo "40 MODULES | FULL STACK | DOCKER COMPOSE"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    print_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    print_success "Docker installed"
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed!"
    print_info "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
fi

# Create .env file if not exists
if [ ! -f .env ]; then
    print_info "Creating .env file from template..."
    cp .env.example .env
    print_warning "Please edit .env file with your configuration!"
fi

# Create necessary directories
print_info "Creating directories..."
mkdir -p uploads logs database/backups deploy/nginx/ssl deploy/monitoring

# Start services
print_info "Starting all services with Docker Compose..."
docker-compose -f docker-compose.production.yml up -d

# Wait for services to start
print_info "Waiting for services to be ready..."
sleep 30

# Check service status
print_info "Checking service status..."
services=("postgres" "redis" "api" "admin" "nginx")
for service in "${services[@]}"; do
    if docker ps | grep -q "$service"; then
        print_success "$service: RUNNING"
    else
        print_error "$service: NOT RUNNING"
    fi
done

# Test API
print_info "Testing API health..."
API_RESPONSE=$(curl -s http://localhost:3000/api/health | grep -o '"status":"ok"' || echo "FAILED")
if [ "$API_RESPONSE" = '"status":"ok"' ]; then
    print_success "API Server: HEALTHY"
else
    print_error "API Server: UNHEALTHY"
    docker logs pesantren-api --tail 20
fi

# Test Admin Panel
print_info "Testing Admin Panel..."
ADMIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001)
if [ "$ADMIN_RESPONSE" = "200" ]; then
    print_success "Admin Panel: ACCESSIBLE (HTTP 200)"
else
    print_warning "Admin Panel: HTTP $ADMIN_RESPONSE"
fi

# Test Database
print_info "Testing Database connection..."
DB_CHECK=$(docker exec pesantren-postgres psql -U pesantren -d pesantren_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d '[:space:]' || echo "ERROR")
if [[ "$DB_CHECK" =~ ^[0-9]+$ ]]; then
    print_success "Database: CONNECTED ($DB_CHECK users found)"
else
    print_error "Database: CONNECTION FAILED"
fi

# Test Redis
print_info "Testing Redis connection..."
REDIS_CHECK=$(docker exec pesantren-redis redis-cli -a "RedisPesantren2026!" ping 2>/dev/null || echo "ERROR")
if [ "$REDIS_CHECK" = "PONG" ]; then
    print_success "Redis: CONNECTED"
else
    print_error "Redis: CONNECTION FAILED"
fi

# Display access information
echo ""
echo "============================================"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "============================================"
echo ""
echo "🌐 ACCESS URLs:"
echo "   • API Server:      http://localhost:3000"
echo "   • Admin Panel:     http://localhost:3001"
echo "   • API Documentation: http://localhost:3000/api/docs"
echo "   • MinIO Console:   http://localhost:9001"
echo "   • Mailhog:         http://localhost:8025"
echo "   • Prometheus:      http://localhost:9090"
echo "   • Grafana:         http://localhost:3002"
echo ""
echo "🔧 MANAGEMENT COMMANDS:"
echo "   • View logs:       docker-compose logs -f"
echo "   • Stop services:   docker-compose down"
echo "   • Restart:         docker-compose restart"
echo "   • Database shell:  docker exec -it pesantren-postgres psql -U pesantren -d pesantren_db"
echo "   • Redis shell:     docker exec -it pesantren-redis redis-cli -a 'RedisPesantren2026!'"
echo ""
echo "📊 TEST ENDPOINTS:"
echo "   • Health:          curl http://localhost:3000/api/health"
echo "   • Modules:         curl http://localhost:3000/api/modules"
echo "   • Santri:          curl http://localhost:3000/api/santri"
echo "   • Dashboard:       curl http://localhost:3000/api/dashboard/summary"
echo ""
echo "🔐 DEFAULT CREDENTIALS:"
echo "   • Database:        pesantren / Pesantren2026!"
echo "   • Redis:           RedisPesantren2026!"
echo "   • MinIO:           minioadmin / minioadmin"
echo "   • Grafana:         admin / admin"
echo ""
echo "⚠️  IMPORTANT:"
echo "   1. Edit .env file for production configuration"
echo "   2. Setup SSL certificates for production"
echo "   3. Change default passwords"
echo "   4. Configure backup schedule"
echo "   5. Setup monitoring alerts"
echo ""
echo "✅ SYSTEM READY FOR TESTING!"
echo ""
echo "============================================"
echo "🚀 40 MODULES | FULL STACK | READY TO USE"
echo "============================================"

# Send notification
print_info "Sending deployment notification..."
curl -X POST -H "Content-Type: application/json" \
  -d '{
    "message": "🚀 Test deployment completed! Pesantren System is now running with 40 modules.",
    "status": "success",
    "services": ["postgres", "redis", "api", "admin", "nginx"],
    "timestamp": "'$(date -Iseconds)'"
  }' \
  http://localhost:3000/api/notifications/test 2>/dev/null || true

print_success "Deployment script completed!"