#!/bin/bash

# Deploy script for 2GB RAM VPS
# Guides you through optimization choices

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Functions
print_header() {
    clear
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}    PMTL_VN - 2GB VPS Deployment${NC}"
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
check_docker() {
    print_section "Checking Docker..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found"
        exit 1
    fi
    print_success "Docker installed"
    
    # Support both legacy `docker-compose` and modern `docker compose`
    if command -v docker-compose &> /dev/null; then
        COMPOSE="docker-compose"
    else
        if docker compose version &> /dev/null; then
            COMPOSE="docker compose"
        else
            print_error "Docker Compose not found (need either `docker-compose` or `docker compose`)"
            exit 1
        fi
    fi

    print_success "Docker Compose detected: ${COMPOSE}"
}

# Choose Meilisearch option
choose_meilisearch() {
    print_section "Meilisearch Configuration (CRITICAL for 2GB!)"
    
    echo -e """
${YELLOW}⚠️  Your VPS has TIGHT MEMORY (2GB)${NC}

Meilisearch uses 700MB-1GB RAM!
You MUST choose how to handle this:

${GREEN}[A] Use Meilisearch Cloud${NC} ⭐ RECOMMENDED
    ✓ FREE tier available (100K documents)
    ✓ No RAM used locally
    ✓ Fast & scalable
    ✓ Setup: 10 minutes
    → Deploy with regular docker-compose.yml

${PURPLE}[B] Disable Meilisearch${NC} ⚡ QUICK FIX
    ✓ Frees 700MB RAM immediately  
    ✓ PostgreSQL search still works
    ✓ Setup: 5 minutes
    → Will remove from dependencies

${RED}[C] Keep Local Meilisearch${NC} 🔧 RISKY
    ⚠ Need 2GB swap + constant monitoring
    ⚠ Tight memory, risk of OOM kills
    ⚠ Slowness likely under load
    → Deploy with docker-compose.prod.2gb.yml
    """
    
    read -p "Choose [A/B/C]: " choice
    echo "$choice"
}

# Setup Meilisearch Cloud
setup_cloud() {
    print_section "Setting up Meilisearch Cloud"
    
    echo -e """
${PURPLE}Step 1: Get Meilisearch Cloud Credentials${NC}

1. Go to: ${BLUE}https://cloud.meilisearch.com${NC}
2. Sign up (free account)
3. Create a new project
4. Copy these values:
   - Instance URL (https://xxx.meilisearch.com)
   - API Key
5. Return here when ready...
    """
    
    read -p "Ready to continue? (y/n): " ready
    if [ "$ready" != "y" ]; then
        return 1
    fi
    
    # Copy environment
    print_section "Configuring environment"
    cp "${SCRIPT_DIR}/.env.2gb" "${SCRIPT_DIR}/.env"
    print_success "Copied .env.2gb → .env"
    
    # Get Cloud credentials
    read -p "Enter Meilisearch Instance URL: " mehli_host
    read -p "Enter Meilisearch API Key: " mehli_key
    
    # Update .env
    sed -i "s|# MEILISEARCH_HOST=.*|MEILISEARCH_HOST=${mehli_host}|" .env
    sed -i "s|# MEILISEARCH_API_KEY=.*|MEILISEARCH_API_KEY=${mehli_key}|" .env
    
    print_success "Meilisearch Cloud configured"
    echo -e "  Host: ${mehli_host}"
    echo -e "  Key: ${mehli_key:0:10}..."
    
    return 0
}

# Setup disabled Meilisearch
disable_meilisearch() {
    print_section "Disabling Meilisearch"
    
    # Copy environment
    cp "${SCRIPT_DIR}/.env.2gb" "${SCRIPT_DIR}/.env"
    print_success "Copied .env.2gb → .env"
    
    # Remove from package.json
    if grep -q "strapi-plugin-meilisearch" BE_PMTL/package.json; then
        print_section "Removing Meilisearch from dependencies..."
        
        # Use sed to remove the line
        sed -i '/strapi-plugin-meilisearch/d' BE_PMTL/package.json
        print_success "Removed strapi-plugin-meilisearch"
        
        print_warning "You'll need to rebuild backend"
    fi
    
    return 0
}

# Setup local Meilisearch
setup_local_meilisearch() {
    print_section "Setting up Local Meilisearch (2GB version)"
    
    # Check swap
    print_section "Checking swap space..."
    
    SWAP_SIZE=$(free -h | grep Swap | awk '{print $2}')
    SWAP_USED=$(free -h | grep Swap | awk '{print $3}')
    
    echo "Current swap: ${SWAP_SIZE}"
    
    if [ "${SWAP_SIZE}" == "0B" ] || [ "${SWAP_SIZE}" == "0M" ]; then
        print_error "No swap found!"
        echo -e """
${YELLOW}⚠️  This is RISKY without swap!${NC}

To create 2GB swap:

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make persistent:
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

Then restart this script.
        """
        
        read -p "Continue anyway? (type 'RISK' to confirm): " risk
        if [ "$risk" != "RISK" ]; then
            return 1
        fi
    fi
    
    print_success "Swap OK: ${SWAP_SIZE}"
    
    # Copy environment
    cp "${SCRIPT_DIR}/.env.2gb" "${SCRIPT_DIR}/.env"
    print_success "Copied .env.2gb → .env"
    
    print_warning "Will deploy with docker-compose.prod.2gb.yml"
    
    return 0
}

# Deploy function
deploy() {
    local compose_file="$1"
    local option="$2"
    
    print_section "Deploying PMTL_VN..."
    
    # Check if .env exists and has values
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        return 1
    fi
    
    if ! grep -q "DATABASE_PASSWORD" .env; then
        print_error ".env is not configured!"
        echo -e "\n${YELLOW}Please edit .env and set:${NC}"
        echo "  - DATABASE_PASSWORD (strong password)"
        echo "  - NEXT_PUBLIC_API_URL"
        echo "  - All APP_KEYS and secrets"
        return 1
    fi
    
    print_section "Building Docker images..."
    
    if [ "$option" = "C" ]; then
        ${COMPOSE} -f "${compose_file}" build || return 1
    else
        ${COMPOSE} build || return 1
    fi
    
    print_success "Docker build complete"
    
    print_section "Starting services..."
    
    if [ "$option" = "C" ]; then
        ${COMPOSE} -f "${compose_file}" up -d || return 1
    else
        ${COMPOSE} up -d || return 1
    fi
    
    print_success "Services started"
    
    # Wait for services
    print_section "Waiting for services to be ready..."
    sleep 15
    
    # Show status
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${GREEN}    ✓ DEPLOYMENT SUCCESSFUL!${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ "$option" = "C" ]; then
        ${COMPOSE} -f "${compose_file}" ps
    else
        ${COMPOSE} ps
    fi
    
    echo ""
    echo -e "${PURPLE}📊 Check Memory Usage:${NC}"
    echo -e "  ${BLUE}free -h${NC}"
    echo -e "  Should be under 1.3GB used"
    echo ""
    
    echo -e "${PURPLE}🔍 Health Check:${NC}"
    echo -e "  ${BLUE}./health-check.sh${NC}"
    echo ""
    
    echo -e "${PURPLE}📋 View Logs:${NC}"
    echo -e "  ${BLUE}${COMPOSE} logs -f${NC}"
    echo ""
    
    return 0
}

# Main flow
main() {
    print_header
    
    check_docker
    
    # Choose Meilisearch option
    option=$(choose_meilisearch)
    
    case $option in
        A|a)
            print_success "Using Meilisearch Cloud"
            setup_cloud || exit 1
            deploy "docker-compose.yml" "A" || exit 1
            ;;
        B|b)
            print_success "Disabling Meilisearch"
            disable_meilisearch || exit 1
            deploy "docker-compose.yml" "B" || exit 1
            ;;
        C|c)
            print_warning "Using Local Meilisearch (risky!)"
            setup_local_meilisearch || exit 1
            deploy "docker-compose.prod.2gb.yml" "C" || exit 1
            ;;
        *)
            print_error "Invalid choice: $option"
            exit 1
            ;;
    esac
    
    print_section "Next Steps:"
    echo ""
    echo -e "1. ${BLUE}Monitor memory:${NC}"
    echo -e "   ${PURPLE}watch -n 1 free -h${NC}"
    echo ""
    echo -e "2. ${BLUE}Run health check:${NC}"
    echo -e "   ${PURPLE}./health-check.sh${NC}"
    echo ""
    echo -e "3. ${BLUE}Setup domain & SSL:${NC}"
    echo -e "   See SETUP_GUIDE.md section 4"
    echo ""
    echo -e "4. ${BLUE}Regular backups:${NC}"
    echo -e "   ${PURPLE}${COMPOSE} exec postgres pg_dump -U strapi_user strapi_db > backup.sql${NC}"
    echo ""
}

main
