# 🚀 PMTL_VN - Docker Deployment Guide

## Quick Start

### 1. Prerequisites
- Docker & Docker Compose installed
- VPS with Ubuntu 22.04+ (recommended)
- Domain name configured with DNS pointing to VPS IP
- SSH access to VPS

### 2. Development (Local Testing)

```bash
# Copy dev environment
cp .env.dev .env

# Start all containers
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f backend   # Backend logs
docker-compose logs -f frontend  # Frontend logs
docker-compose logs -f nginx     # Nginx logs

# Stop all containers
docker-compose down

# Reset everything (remove volumes)
docker-compose down -v
```

**Access URLs:**
- Frontend: http://localhost
- Backend API: http://localhost/api
- Backend Admin: http://localhost/admin
- Database: localhost:5432

---

## 3. Production Deployment (VPS)

### Step 1: Setup VPS Server

```bash
# SSH to VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -sSL https://get.docker.com | sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add current user to docker group (if needed)
usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Clone Project & Setup

```bash
# Create app directory
mkdir -p /apps/pmtl-vn && cd /apps/pmtl-vn

# Clone your repository
git clone <your-repo-url> .

# Or if using existing code, upload via rsync/SCP
```

### Step 3: Configure Production Environment

```bash
# Copy production env file
cp .env.production .env

# Edit with your values
nano .env
```

**IMPORTANT - Generate Strong Keys:**

```bash
# Generate all required secrets
node -e "
console.log('APP_KEYS=', require('crypto').randomBytes(16).toString('base64'));
console.log('API_TOKEN_SALT=', require('crypto').randomBytes(16).toString('base64'));
console.log('ADMIN_JWT_SECRET=', require('crypto').randomBytes(16).toString('base64'));
console.log('JWT_SECRET=', require('crypto').randomBytes(16).toString('base64'));
console.log('TRANSFER_TOKEN_SALT=', require('crypto').randomBytes(16).toString('base64'));
"
```

Update `.env` with these values.

### Step 4: Build & Deploy

```bash
# Build Docker images (may take 5-10 minutes)
docker-compose build

# Start services
docker-compose up -d

# Verify all services are running
docker-compose ps

# Check logs for errors
docker-compose logs
```

### Step 5: Database Initialization (First Time Only)

```bash
# Wait 30 seconds for DB to be ready, then run migrations
sleep 30
docker-compose exec backend npm run strapi migrate latest

# Optional: Seed initial data
# docker-compose exec backend npm run seed:core
```

### Step 6: Enable SSL with Let's Encrypt

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Get SSL certificate (update domain name!)
certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  -m your-email@example.com \
  --agree-tos --non-interactive

# Update Nginx config
# 1. Uncomment HTTPS and redirect sections in nginx/conf.d/default.conf
# 2. Replace 'yourdomain.com' with your actual domain
# 3. Save and run:
docker-compose restart nginx

# Auto-renewal (runs daily at 2 AM)
# Already configured by Certbot
certbot renew --dry-run  # Test renewal
```

### Step 7: Verify Deployment

```bash
# Check service health
curl http://localhost
curl http://localhost/api/content-manager/collection-types

# Check database connection
docker-compose exec backend npm run strapi version

# View real-time logs
docker-compose logs -f
```

---

## 4. Ongoing Management

### Monitoring & Logs

```bash
# Real-time logs (all services)
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx

# View last 100 lines
docker-compose logs --tail 100

# Export logs
docker-compose logs > logs.txt
```

### Database Backup & Restore

```bash
# Manual backup
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql

# Restore from backup
docker-compose exec -T postgres psql -U strapi_user strapi_db < backup.sql

# Backup with compression
docker-compose exec postgres pg_dump -U strapi_user strapi_db | gzip > backup-$(date +%Y%m%d).sql.gz
```

### Update Application Code

```bash
# Update code from Git
git pull origin main

# Rebuild Docker images
docker-compose build

# Restart services with new code
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs
```

### Scale Resources (if needed)

```bash
# Scale frontend instances (for load balancing)
docker-compose up -d --scale frontend=3

# Scale backend (uses same image)
docker-compose up -d --scale backend=2
```

### Restart Services

```bash
# Restart specific service
docker-compose restart backend

# Restart all
docker-compose restart

# Rebuild and restart
docker-compose up -d --build backend
```

### Cleanup Old Docker Images

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
docker system df
```

---

## 5. Troubleshooting

### Backend container not starting

```bash
# Check backend logs
docker-compose logs backend

# Verify database connection
docker-compose exec backend npm run strapi version

# Check database exists
docker-compose exec postgres psql -U strapi_user -l
```

### Frontend not loading

```bash
# Check frontend logs
docker-compose logs frontend

# Verify API connectivity
docker-compose exec frontend curl http://backend:1337/api

# Check Nginx routing
docker-compose exec nginx curl http://frontend:3000
```

### Database connection issues

```bash
# Check PostgreSQL status
docker-compose exec postgres pg_isready

# Connect to database directly
docker-compose exec postgres psql -U strapi_user -d strapi_db

# Check db config
docker-compose exec backend env | grep DATABASE
```

### Out of disk space

```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -a --volumes

# Remove old logs
docker-compose logs --timestamps | head -20 > /dev/null
```

### SSL certificate not working

```bash
# Check certificate status
certbot certificates

# Test renewal
certbot renew --dry-run

# Manually renew
certbot renew --force-renewal

# Verify in Nginx
docker-compose logs nginx | grep ssl
```

---

## 6. Performance Tuning

### Nginx Caching

```nginx
# Already configured in nginx.conf
# Static assets cached for 7 days
# API requests not cached
```

### Database Connection Pooling

Edit `BE_PMTL/config/database.ts`:
```typescript
pool: { 
  min: env.int('DATABASE_POOL_MIN', 5),      // Increase from 2
  max: env.int('DATABASE_POOL_MAX', 20)      // Increase from 10
}
```

### Next.js ISR (Incremental Static Regeneration)

Configure in route segments:
```typescript
export const revalidate = 3600; // Revalidate every hour
```

---

## 7. Security Best Practices

✅ **Already Applied:**
- Non-root container users
- Environment variable isolation
- Health checks
- Restart policies
- Network isolation

✅ **You Should Do:**

```bash
# 1. Change default passwords
# Edit .env with strong passwords

# 2. Setup SSH key-based auth
# Disable password auth in /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 3. Setup firewall
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

# 4. Enable automatic updates
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades

# 5. Monitor logs regularly
docker-compose logs --tail 50 | grep ERROR
```

---

## 8. Domain & SSL Setup

### DNS Configuration

Point your domain to VPS:
```
A Record: yourdomain.com -> YOUR_VPS_IP
A Record: www.yourdomain.com -> YOUR_VPS_IP
```

### Automatic SSL Renewal

```bash
# Certbot auto-renewal runs daily (systemctl list-timers)
# Verify it's working:
systemctl status certbot.timer

# Manual test:
certbot renew --dry-run
```

### Custom Domain API URL

Update in `.env`:
```bash
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
BACKEND_INTERNAL_URL=http://backend:1337  # For internal services
```

---

## 9. CI/CD Integration (Optional)

### Auto-Deploy on Git Push

```bash
# On VPS, setup Git hook
cat > /apps/pmtl-vn/.git/hooks/post-receive << 'EOF'
#!/bin/bash
cd /apps/pmtl-vn
git checkout -f
docker-compose pull
docker-compose up -d --build
EOF

chmod +x /apps/pmtl-vn/.git/hooks/post-receive
```

Or use GitHub Actions:
- See `.github/workflows/deploy.yml` (if available)

---

## 10. System info

| Component | Technology | Version |
|-----------|-----------|---------|
| Backend | Strapi | v5 |
| Frontend | Next.js | 16 |
| Database | PostgreSQL | 16 |
| Web Server | Nginx | Alpine |
| Container Runtime | Docker | Latest |

---

## 📞 Support Commands

```bash
# Check all services status
docker-compose ps -a

# Get service info
docker inspect pmtl-backend

# Resource usage
docker stats

# Network details
docker network inspect pmtl-network

# View environment
docker-compose exec backend env
```

---

## 📖 Useful Links

- Strapi Docs: https://docs.strapi.io
- Next.js Docs: https://nextjs.org/docs
- Docker Docs: https://docs.docker.com
- Let's Encrypt: https://letsencrypt.org
- Nginx Docs: https://nginx.org/en/docs

---

**Last updated:** 2024
**Maintainer:** Your Dev Team
