#!/bin/bash

# 🚀 PMTL-VN Complete VPS Setup Script
# Clones both repos, setup Docker, and deploy everything
# Usage: ./vps-setup.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
REPO_FE="https://github.com/markprovjp/PMTL-FE"
REPO_BE="https://github.com/markprovjp/PMTL-BE"
APP_DIR="$HOME/pmtl-vn"  # Use home directory to avoid permission issues

# Functions
print_header() {
    clear
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}    PMTL-VN Complete VPS Setup${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${PURPLE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
check_env() {
    print_section "Checking environment..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Install Docker first!"
        exit 1
    fi
    print_success "Docker version: $(docker --version)"
    
    if ! command -v git &> /dev/null; then
        print_error "Git not found. Install Git first!"
        exit 1
    fi
    print_success "Git installed"
    
    # Check swap (install procps if needed)
    if ! command -v free &> /dev/null; then
        print_warning "Installing procps for memory info..."
        apt-get update -qq 2>/dev/null
        apt-get install -y -qq procps > /dev/null 2>&1
    fi
    SWAP=$(free -h 2>/dev/null | grep Swap | awk '{print $2}' || echo "Unknown")
    print_success "Swap available: $SWAP"
}

# Clone repositories
clone_repos() {
    print_section "Cloning repositories..."
    
    if [ -d "$APP_DIR" ]; then
        print_warning "$APP_DIR already exists"
        read -p "Overwrite? (y/n): " overwrite
        if [ "$overwrite" = "y" ]; then
            rm -rf "$APP_DIR"
        else
            print_success "Using existing $APP_DIR"
            return
        fi
    fi
    
    mkdir -p "$APP_DIR" 2>/dev/null || {
        print_warning "Cannot create $APP_DIR, attempting with elevated privileges..."
        sudo mkdir -p "$APP_DIR" || {
            print_error "Failed to create $APP_DIR"
            print_warning "Make sure you have write permissions to the directory"
            exit 1
        }
    }
    cd "$APP_DIR"
    
    print_section "Cloning Frontend..."
    git clone "$REPO_FE" fe-pmtl
    print_success "Frontend cloned"
    
    print_section "Cloning Backend..."
    git clone "$REPO_BE" BE_PMTL
    print_success "Backend cloned"
    
    cd "$APP_DIR"
}

# Copy Docker files (from our pre-created setup)
setup_docker_files() {
    print_section "Setting up Docker configuration..."
    
    # Create docker-compose.yml and other files
    # These will be copied from existing project OR created fresh
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_warning "docker-compose.yml not found, creating..."
        
        # Create minimal docker-compose for both repos
        cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: pmtl-postgres
    restart: always
    environment:
      POSTGRES_DB: ${DATABASE_NAME:-strapi_db}
      POSTGRES_USER: ${DATABASE_USERNAME:-strapi_user}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD:-change_me}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "${DATABASE_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DATABASE_USERNAME:-strapi_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - pmtl-network

  backend:
    build:
      context: ./BE_PMTL
      dockerfile: Dockerfile
    container_name: pmtl-backend
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      NODE_ENV: ${NODE_ENV:-production}
      NODE_OPTIONS: --max-old-space-size=384
      HOST: 0.0.0.0
      PORT: ${BACKEND_PORT:-1337}
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: ${DATABASE_NAME:-strapi_db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-strapi_user}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-change_me}
      DATABASE_SSL: ${DATABASE_SSL:-false}
      APP_KEYS: ${APP_KEYS:-default_key}
      API_TOKEN_SALT: ${API_TOKEN_SALT:-default_salt}
      ADMIN_JWT_SECRET: ${ADMIN_JWT_SECRET:-default_secret}
      JWT_SECRET: ${JWT_SECRET:-default_jwt}
      TRANSFER_TOKEN_SALT: ${TRANSFER_TOKEN_SALT:-default_transfer}
    ports:
      - "${BACKEND_PORT:-1337}:1337"
    volumes:
      - ./BE_PMTL/public/uploads:/app/public/uploads
      - ./BE_PMTL/.tmp:/app/.tmp
    networks:
      - pmtl-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:1337/admin"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

  frontend:
    build:
      context: ./fe-pmtl
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:-http://backend:1337}
    container_name: pmtl-frontend
    restart: always
    depends_on:
      - backend
    environment:
      NODE_ENV: ${NODE_ENV:-production}
      NODE_OPTIONS: --max-old-space-size=256
      NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:-http://backend:1337}
      NEXT_PUBLIC_SITE_URL: ${NEXT_PUBLIC_SITE_URL:-http://localhost:3000}
    ports:
      - "${FRONTEND_PORT:-3000}:3000"
    networks:
      - pmtl-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

  nginx:
    image: nginx:alpine
    container_name: pmtl-nginx
    restart: always
    depends_on:
      - frontend
      - backend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./certbot/conf:/etc/letsencrypt:ro
      - ./certbot/www:/var/www/certbot:ro
    networks:
      - pmtl-network

volumes:
  postgres_data:
    driver: local

networks:
  pmtl-network:
    driver: bridge
EOF
        
        print_success "docker-compose.yml created"
    fi
}

# Setup environment
setup_environment() {
    print_section "Setting up environment files..."
    
    cd "$APP_DIR"
    
    # Create .env if not exists
    if [ ! -f ".env" ]; then
        cat > .env << 'EOF'
NODE_ENV=production

# Database
DATABASE_NAME=strapi_db
DATABASE_USERNAME=strapi_user
DATABASE_PASSWORD=CHANGE_THIS_PASSWORD
DATABASE_PORT=5432

# Backend
BACKEND_PORT=1337

# Frontend
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost/api
NEXT_PUBLIC_SITE_URL=http://localhost

# Strapi Keys - GENERATE NEW!
APP_KEYS=default_key_change_this
API_TOKEN_SALT=default_salt_change_this
ADMIN_JWT_SECRET=default_secret_change_this
JWT_SECRET=default_jwt_change_this
TRANSFER_TOKEN_SALT=default_transfer_change_this

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@yourdomain.com
EOF
        
        print_success ".env created (template)"
        print_warning "IMPORTANT: Edit .env with your values:"
        print_warning "  - DATABASE_PASSWORD (strong!)"
        print_warning "  - Generate APP_KEYS and secrets"
        print_warning "  - Set NEXT_PUBLIC_API_URL to your domain"
    fi
}

# Create Nginx config
setup_nginx() {
    print_section "Setting up Nginx..."
    
    mkdir -p "$APP_DIR/nginx/conf.d"
    
    # Create nginx.conf
    if [ ! -f "$APP_DIR/nginx/nginx.conf" ]; then
        cat > "$APP_DIR/nginx/nginx.conf" << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
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
    client_max_body_size 100M;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss;

    include /etc/nginx/conf.d/*.conf;
}
EOF
        print_success "nginx.conf created"
    fi
    
    # Create default.conf
    if [ ! -f "$APP_DIR/nginx/conf.d/default.conf" ]; then
        cat > "$APP_DIR/nginx/conf.d/default.conf" << 'EOF'
server {
    listen 80;
    server_name _;

    location /api/ {
        proxy_pass http://backend:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /admin/ {
        proxy_pass http://backend:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /uploads/ {
        proxy_pass http://backend:1337;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_valid 7d;
    }

    location / {
        proxy_pass http://frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
        print_success "nginx/conf.d/default.conf created"
    fi
}

# Check Dockerfiles
check_dockerfiles() {
    print_section "Checking Dockerfiles..."
    
    if [ ! -f "$APP_DIR/BE_PMTL/Dockerfile" ]; then
        print_warning "BE_PMTL/Dockerfile not found!"
        print_warning "Backend repo should have Dockerfile"
        return 1
    fi
    print_success "Backend Dockerfile found"
    
    if [ ! -f "$APP_DIR/fe-pmtl/Dockerfile" ]; then
        print_warning "fe-pmtl/Dockerfile not found!"
        print_warning "Frontend repo should have Dockerfile"
        return 1
    fi
    print_success "Frontend Dockerfile found"
    
    return 0
}

# Build images
build_images() {
    print_section "Building Docker images..."
    
    cd "$APP_DIR"
    
    docker-compose build --no-cache
    
    print_success "Docker images built"
}

# Start services
start_services() {
    print_section "Starting services..."
    
    cd "$APP_DIR"
    
    docker-compose up -d
    
    print_success "Services started"
    
    # Wait for health
    sleep 15
    
    echo ""
    docker-compose ps
}

# Health check
health_check() {
    print_section "Health Check..."
    
    cd "$APP_DIR"
    
    echo ""
    echo "Container Status:"
    docker-compose ps
    
    echo ""
    echo "Memory Usage:"
    free -h
    
    echo ""
    echo "Testing connectivity..."
    if docker-compose exec -T frontend curl -s http://localhost:3000 > /dev/null 2>&1; then
        print_success "Frontend responding"
    else
        print_warning "Frontend not ready yet"
    fi
    
    if docker-compose exec -T backend curl -s http://localhost:1337/admin > /dev/null 2>&1; then
        print_success "Backend responding"
    else
        print_warning "Backend not ready yet (normal, may need time)"
    fi
}

# Main flow
main() {
    print_header
    
    check_env
    clone_repos
    setup_docker_files
    setup_environment
    setup_nginx
    
    if ! check_dockerfiles; then
        print_error "Dockerfiles missing in repos!"
        print_warning "Make sure PMTL-FE and PMTL-BE have Dockerfile"
        exit 1
    fi
    
    print_section "Ready to build and start?"
    read -p "Continue? (y/n): " continue
    if [ "$continue" != "y" ]; then
        print_warning "Setup cancelled"
        exit 0
    fi
    
    build_images
    start_services
    health_check
    
    print_section "✅ SETUP COMPLETE!"
    echo ""
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo ""
    echo "1. Edit .env with your secrets:"
    echo -e "   ${BLUE}nano .env${NC}"
    echo ""
    echo "2. Check status:"
    echo -e "   ${BLUE}docker-compose ps${NC}"
    echo ""
    echo "3. View logs:"
    echo -e "   ${BLUE}docker-compose logs -f${NC}"
    echo ""
    echo "4. Setup domain & SSL (when ready):"
    echo -e "   See setup-domain.sh script"
    echo ""
    echo -e "${YELLOW}Access:${NC}"
    echo -e "   Frontend: http://$(hostname -I | awk '{print $1}')"
    echo -e "   API: http://$(hostname -I | awk '{print $1}')/api"
    echo -e "   Admin: http://$(hostname -I | awk '{print $1}')/admin"
    echo ""
}

main
