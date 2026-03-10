#!/bin/bash

# 🌐 Setup Domain & SSL for PMTL-VN
# Run this AFTER vps-setup.sh is complete

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

APP_DIR="/apps/pmtl-vn"

print_header() {
    clear
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Domain & SSL Setup for PMTL-VN${NC}"
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

# Get domain from user
get_domain() {
    print_section "Domain Configuration"
    
    echo -e "${YELLOW}Your VPS IP:${NC}"
    hostname -I
    
    echo ""
    read -p "Enter your domain (e.g., yourdomain.com): " domain
    
    if [ -z "$domain" ]; then
        print_error "Domain cannot be empty"
        exit 1
    fi
    
    echo "$domain"
}

# Check DNS
check_dns() {
    local domain=$1
    
    print_section "Checking DNS..."
    
    echo -e "Waiting for DNS propagation... (this takes 5-30 minutes)"
    echo -e "Once your DNS A record points to this VPS IP, continue."
    echo ""
    echo -e "Current VPS IP: $(hostname -I | awk '{print $1}')"
    echo ""
    
    read -p "Press Enter when DNS is updated, or Ctrl+C to skip..."
    
    if ping -c 1 "$domain" 2>/dev/null; then
        print_success "DNS resolved to: $(ping -c 1 "$domain" | head -1 | awk '{print $4}' | cut -d'(' -f2 | cut -d')' -f1)"
    else
        print_warning "DNS not yet propagated, continuing anyway..."
    fi
}

# Get SSL certificate
get_ssl_certificate() {
    local domain=$1
    
    print_section "Installing Certbot for SSL..."
    
    if ! command -v certbot &> /dev/null; then
        apt-get update
        apt-get install -y certbot
        print_success "Certbot installed"
    else
        print_success "Certbot already installed"
    fi
    
    print_section "Getting SSL Certificate from Let's Encrypt..."
    
    read -p "Enter your email (for Let's Encrypt): " email
    
    certbot certonly --standalone \
        -d "$domain" \
        -d "www.$domain" \
        -m "$email" \
        --agree-tos \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        print_success "SSL certificate obtained!"
        print_success "Certificate location: /etc/letsencrypt/live/$domain/"
    else
        print_error "Failed to get SSL certificate"
        return 1
    fi
}

# Update Nginx config
update_nginx_config() {
    local domain=$1
    
    print_section "Updating Nginx configuration..."
    
    cd "$APP_DIR"
    
    # Backup original
    cp nginx/conf.d/default.conf nginx/conf.d/default.conf.bak
    
    # Create new config with SSL
    cat > nginx/conf.d/default.conf << EOFNGINX
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name $domain www.$domain;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $domain www.$domain;
    
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location /api/ {
        proxy_pass http://backend:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /admin/ {
        proxy_pass http://backend:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /uploads/ {
        proxy_pass http://backend:1337;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_valid 7d;
    }

    location / {
        proxy_pass http://frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOFNGINX
    
    print_success "Nginx config updated"
}

# Mount SSL certs in Docker
mount_ssl_certs() {
    local domain=$1
    
    print_section "Setting up SSL cert volumes in Docker..."
    
    cd "$APP_DIR"
    
    # Create directories for certbot
    mkdir -p certbot/conf
    mkdir -p certbot/www
    
    # Copy certificates to project directory
    cp -r "/etc/letsencrypt/live/$domain" certbot/conf/ 2>/dev/null || true
    
    print_success "SSL directories created"
}

# Restart Nginx
restart_nginx() {
    print_section "Restarting Nginx..."
    
    cd "$APP_DIR"
    
    docker-compose restart nginx
    
    sleep 5
    
    if docker-compose exec nginx nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx restarted successfully"
    else
        print_error "Nginx config error"
        return 1
    fi
}

# Setup auto-renewal
setup_auto_renewal() {
    local domain=$1
    
    print_section "Setting up automatic SSL renewal..."
    
    # Create renewal script
    cat > /usr/local/bin/renew-ssl-pmtl << 'EOFRENEW'
#!/bin/bash
certbot renew --quiet
if [ $? -eq 0 ]; then
    docker-compose restart nginx
fi
EOFRENEW
    
    chmod +x /usr/local/bin/renew-ssl-pmtl
    
    # Add to crontab (run daily at 2 AM)
    if ! crontab -l 2>/dev/null | grep -q "renew-ssl-pmtl"; then
        (crontab -l 2>/dev/null || echo "") | grep -v renew-ssl-pmtl | crontab -
        echo "0 2 * * * /usr/local/bin/renew-ssl-pmtl" | crontab -
    fi
    
    print_success "Auto-renewal setup (daily at 2 AM)"
}

# Test HTTPS
test_https() {
    local domain=$1
    
    print_section "Testing HTTPS..."
    
    sleep 5
    
    echo "Testing: https://$domain"
    
    if curl -sI "https://$domain" | grep -q "200\|301\|302"; then
        print_success "HTTPS working!"
    else
        print_warning "HTTPS test may have failed, check manually"
    fi
    
    echo ""
    echo "Visit https://$domain in browser"
}

# Update .env
update_env_domain() {
    local domain=$1
    
    print_section "Updating .env with domain..."
    
    cd "$APP_DIR"
    
    # Update API URL
    sed -i "s|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=https://$domain/api|" .env
    sed -i "s|NEXT_PUBLIC_SITE_URL=.*|NEXT_PUBLIC_SITE_URL=https://$domain|" .env
    
    print_success ".env updated with domain"
    
    # Restart backend to apply changes
    docker-compose restart backend
}

# Main flow
main() {
    print_header
    
    # Get domain
    domain=$(get_domain)
    print_success "Domain: $domain"
    
    # Check DNS
    check_dns "$domain"
    
    # Get SSL
    if ! get_ssl_certificate "$domain"; then
        print_error "SSL setup failed"
        exit 1
    fi
    
    # Update Nginx
    update_nginx_config "$domain"
    
    # Mount certs
    mount_ssl_certs "$domain"
    
    # Restart
    if ! restart_nginx; then
        print_error "Nginx restart failed, restoring backup..."
        cp nginx/conf.d/default.conf.bak nginx/conf.d/default.conf
        docker-compose restart nginx
        exit 1
    fi
    
    # Auto-renewal
    setup_auto_renewal "$domain"
    
    # Update .env
    update_env_domain "$domain"
    
    # Test
    test_https "$domain"
    
    print_section "✅ Domain & SSL Setup Complete!"
    echo ""
    echo -e "${YELLOW}Access your site:${NC}"
    echo -e "   https://$domain"
    echo -e "   https://www.$domain"
    echo ""
    echo -e "${YELLOW}Admin panel:${NC}"
    echo -e "   https://$domain/admin"
    echo ""
    echo -e "${YELLOW}Certificate info:${NC}"
    certbot certificates
    echo ""
}

main
