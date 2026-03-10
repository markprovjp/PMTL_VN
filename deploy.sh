#!/bin/bash

# PMTL_VN - Quick Deployment Script
# Usage: ./deploy.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker is installed"

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Setup environment
setup_env() {
    print_header "Setting up $ENVIRONMENT environment"

    if [ "$ENVIRONMENT" = "prod" ]; then
        ENV_FILE=".env.production"
    else
        ENV_FILE=".env.dev"
    fi

    if [ ! -f "$ENV_FILE" ]; then
        print_error "$ENV_FILE not found"
        exit 1
    fi

    if [ -f ".env" ]; then
        print_warning ".env already exists, backing up to .env.backup"
        cp .env .env.backup
    fi

    cp "$ENV_FILE" .env
    print_success "Environment file configured"

    if [ "$ENVIRONMENT" = "prod" ]; then
        print_warning "PRODUCTION MODE - Please update secrets in .env:"
        print_warning "  - DATABASE_PASSWORD"
        print_warning "  - APP_KEYS, API_TOKEN_SALT, ADMIN_JWT_SECRET, etc."
        print_warning "  - NEXT_PUBLIC_API_URL (set to your domain)"
        read -p "Press Enter to continue..."
    fi
}

# Build containers
build_images() {
    print_header "Building Docker images"
    docker-compose build
    print_success "Docker images built successfully"
}

# Start services
start_services() {
    print_header "Starting services"
    docker-compose up -d
    print_success "Services started"

    print_header "Waiting for services to be healthy"
    sleep 10

    echo "Service Status:"
    docker-compose ps
}

# Initialize database (first run only)
init_database() {
    if [ "$ENVIRONMENT" = "prod" ]; then
        print_header "Initializing database"
        sleep 5
        docker-compose exec -T backend npm run strapi migrate latest || true
        print_success "Database initialized"
    fi
}

# Show URLs
show_urls() {
    print_header "Deployment Complete!"

    if [ "$ENVIRONMENT" = "dev" ]; then
        echo -e "Frontend: ${GREEN}http://localhost${NC}"
        echo -e "API: ${GREEN}http://localhost/api${NC}"
        echo -e "Admin: ${GREEN}http://localhost/admin${NC}"
        echo -e "Database: localhost:5432"
    else
        DOMAIN=$(grep NEXT_PUBLIC_SITE_URL .env | cut -d= -f2)
        echo -e "Frontend: ${GREEN}$DOMAIN${NC}"
        echo -e "API: ${GREEN}$DOMAIN/api${NC}"
        echo -e "Admin: ${GREEN}$DOMAIN/admin${NC}"
    fi

    echo -e "\n${YELLOW}Useful commands:${NC}"
    echo "  View logs:       docker-compose logs -f"
    echo "  Backend logs:    docker-compose logs -f backend"
    echo "  Restart service: docker-compose restart [backend|frontend|nginx]"
    echo "  Stop services:   docker-compose down"
    echo "  Database backup: docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql"
}

# Cleanup old containers
cleanup() {
    print_header "Cleaning up old containers and images"
    docker system prune -f --volumes
    print_success "Cleanup complete"
}

# Main
main() {
    print_header "PMTL_VN Deployment Script - $ENVIRONMENT Environment"

    if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
        print_error "Invalid environment. Use 'dev' or 'prod'"
        exit 1
    fi

    check_docker
    setup_env
    build_images
    start_services
    init_database
    show_urls

    echo -e "\n${GREEN}🎉 Deployment successful!${NC}\n"
}

# Run main
main
