# 🚀 PMTL_VN - Docker & Production Deployment Complete Guide

**Tiếng Anh:** [English Version](#english-version)

---

## 📌 Tóm tắt Quick Setup

### Dev (Máy tính của bạn)
```bash
cp .env.dev .env              # Copy environment dev
docker-compose up -d          # Start containers
# Truy cập: http://localhost
```

### Prod (VPS)
```bash
cd /apps/pmtl-vn              # SSH vào VPS
cp .env.production .env
nano .env                     # Edit: passwords, domain, keys
./deploy.sh prod              # Hoặc: deploy.bat prod (Windows)
```

---

## 🎯 Lợi ích của Docker Setup này

✅ **Easy Management** - Một lệnh start/stop/restart tất cả  
✅ **Dev-to-Prod** - Cùng Docker image, chỉ swap environment  
✅ **Domain Ready** - Nginx + SSL + Domain riêng  
✅ **Database Persistent** - PostgreSQL volumes tự động  
✅ **Health Monitoring** - Tự động detect & restart unhealthy containers  
✅ **Scalable** - Dễ scale thêm backend/frontend instances  
✅ **Security** - Non-root users, environment isolation, firewall  
✅ **Performance** - Multi-stage Docker builds, gzip compression, caching  

---

## 📁 Files được tạo

```
PMTL_VN/
├── docker-compose.yml              # Main - Config tất cả services
├── DOCKER_README.md                # Vietnamese guide (basic)
├── DEPLOYMENT_GUIDE.md             # English guide (detailed)
├── deploy.sh                       # Linux/Mac deploy script
├── deploy.bat                      # Windows deploy script
├── health-check.sh                 # Monitor health
├── .env.dev                        # Dev environment
├── .env.production                 # Prod environment (template)
│
├── BE_PMTL/
│   ├── Dockerfile                  # Strapi production build
│   └── .dockerignore               # Optimize Docker layer
│
├── fe-pmtl/
│   ├── Dockerfile                  # Next.js production build
│   └── .dockerignore               # Optimize Docker layer
│
└── nginx/
    ├── nginx.conf                  # Main Nginx config
    └── conf.d/
        └── default.conf            # Virtual hosts + SSL
```

---

## 🔧 Installation & Setup

### Bước 1: Install Docker

#### Ubuntu/Debian (VPS)
```bash
# Install Docker
curl -sSL https://get.docker.com | sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version
```

#### Mac (Local)
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Then in terminal:
docker --version
docker-compose --version
```

#### Windows (Local)
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Run as Administrator
docker --version
docker-compose --version
```

---

### Bước 2: Setup Environment

#### Development

```bash
# Copy dev environment
cp .env.dev .env

# Khởi động
docker-compose up -d

# Kiểm tra
docker-compose ps
```

**Truy cập:**
- Frontend: http://localhost
- API: http://localhost/api
- Admin: http://localhost/admin
- Database: localhost:5432

---

#### Production (VPS)

```bash
# 1. SSH vào VPS
ssh root@your-vps-ip

# 2. Clone project
git clone <your-repo-url> /apps/pmtl-vn
cd /apps/pmtl-vn

# 3. Copy production environment
cp .env.production .env

# 4. Edit environment
nano .env
```

**Các giá trị cần update:**

```bash
# Database (CREATE STRONG PASSWORD!)
DATABASE_PASSWORD=your_super_secure_password_32_chars

# Domain của bạn
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
NEXT_PUBLIC_SITE_URL=https://yourdomain.com

# Strapi Keys (GENERATE MỚI!)
# Chạy lệnh này:
node -e "
const crypto = require('crypto');
console.log('APP_KEYS=' + crypto.randomBytes(16).toString('base64'));
console.log('API_TOKEN_SALT=' + crypto.randomBytes(16).toString('base64'));
console.log('ADMIN_JWT_SECRET=' + crypto.randomBytes(16).toString('base64'));
console.log('JWT_SECRET=' + crypto.randomBytes(16).toString('base64'));
console.log('TRANSFER_TOKEN_SALT=' + crypto.randomBytes(16).toString('base64'));
"

# Copy kết quả vào .env
```

---

### Bước 3: Deploy

#### Automatic (Recommended)

```bash
# Linux/Mac
chmod +x deploy.sh
./deploy.sh prod

# Windows
deploy.bat prod
```

Script sẽ:
1. ✅ Check Docker/Docker Compose
2. ✅ Setup environment
3. ✅ Build Docker images
4. ✅ Start containers
5. ✅ Init database
6. ✅ Show access URLs

#### Manual

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Initialize database (first time only)
sleep 30
docker-compose exec backend npm run strapi migrate latest

# Check status
docker-compose ps
docker-compose logs
```

---

### Bước 4: Setup Domain & SSL

#### Step 4.1: Configure DNS

Thêm A record tại DNS provider (Cloudflare, Route53, etc.):

```
Type: A
Name: yourdomain.com
Value: YOUR_VPS_IP

Type: A  
Name: www.yourdomain.com
Value: YOUR_VPS_IP
```

Wait 5-10 minutes for DNS propagation.

#### Step 4.2: Update Nginx Config

```bash
# Edit Nginx config
nano nginx/conf.d/default.conf

# Uncomment HTTPS section, replace yourdomain.com with your domain
# Save (Ctrl+O, Enter, Ctrl+X)
```

#### Step 4.3: Enable SSL

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Get certificate (replace domain!)
certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  -m your-email@gmail.com \
  --agree-tos \
  --non-interactive

# Restart Nginx
docker-compose restart nginx

# Verify
curl https://yourdomain.com
```

**Auto Renewal:**
```bash
# Test renewal
certbot renew --dry-run

# Certificate auto-renews daily (Certbot cron job)
```

---

## 🎮 Quản lý Services

### View Status

```bash
# List all services
docker-compose ps

# Detailed view
docker-compose ps -a

# Resource usage
docker stats

# Network details
docker network inspect pmtl-network
```

### Logs

```bash
# All logs real-time
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx

# Last N lines
docker-compose logs --tail 100 backend

# Save to file
docker-compose logs > app-logs.txt
```

### Control

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Restart specific service
docker-compose restart backend

# Stop specific service
docker-compose stop backend

# Start stopped service
docker-compose start backend
```

### Update Code

```bash
# Get latest code
git pull origin main

# Rebuild images
docker-compose build

# Apply changes
docker-compose up -d
docker-compose logs -f
```

---

## 🗄️ Database Backup & Restore

### Backup

```bash
# Simple backup
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql

# Compressed backup
docker-compose exec postgres pg_dump -U strapi_user strapi_db | gzip > backup-$(date +%Y%m%d).sql.gz

# List backups
ls -lh backup*.sql*
```

### Restore

```bash
# From backup.sql
docker-compose exec -T postgres psql -U strapi_user strapi_db < backup.sql

# From backup.sql.gz
gunzip -c backup.sql.gz | docker-compose exec -T postgres psql -U strapi_user strapi_db
```

### Database Access

```bash
# Connect to database
docker-compose exec postgres psql -U strapi_user -d strapi_db

# Commands:
# \dt              - List tables
# \du              - List users
# SELECT * FROM ... - Query data
# \q               - Quit
```

---

## 🔍 Troubleshooting

### Backend not starting

```bash
# Check logs
docker-compose logs backend

# Verify database
docker-compose ps postgres
docker-compose exec postgres pg_isready

# Check env vars
docker-compose exec backend env | grep DATABASE

# Manual database migration
docker-compose exec backend npm run strapi migrate latest
```

### Frontend not loading

```bash
# Check logs
docker-compose logs frontend

# Test API connectivity
docker-compose exec frontend curl http://backend:1337/api

# Check Nginx routing
docker-compose exec nginx curl http://frontend:3000
```

### Nginx/Domain issues

```bash
# Check Nginx config
docker-compose exec nginx nginx -t

# Test connectivity
curl -I http://localhost
curl -I https://yourdomain.com

# Check logs
docker-compose logs nginx
```

### Out of disk space

```bash
# Check usage
df -h

# Clean Docker
docker system prune -a --volumes

# Check before/after
du -sh /var/lib/docker
```

### Connection timeout

```bash
# Restart all services
docker-compose restart

# Rebuild if persistent
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔒 Security Checklist

- [ ] Update DATABASE_PASSWORD in .env
- [ ] Generate & update all APP_KEYS, JWT secrets
- [ ] Set NEXT_PUBLIC_API_URL to your domain (https://)
- [ ] Enable SSL certificate
- [ ] Setup firewall (ufw)
- [ ] Disable SSH password auth
- [ ] Enable auto-updates
- [ ] Regular backups
- [ ] Monitor logs for errors
- [ ] Keep Docker images updated

---

## 📊 Performance Tips

### Database
```bash
# Check slow queries
docker-compose exec postgres psql -U strapi_user -d strapi_db
# \timing on
```

### Frontend (Next.js)
```typescript
// app/layout.tsx
export const revalidate = 3600;  // ISR - revalidate every hour
```

### Backend (Strapi)
```typescript
// config/database.ts
pool: { 
  min: 5,    // Connection pool minimum (was 2)
  max: 20    // Connection pool maximum (was 10)
}
```

### Nginx (already optimized)
- Gzip compression enabled
- Static caching: 7 days
- Rate limiting: 30 req/s for API

---

## 📚 Common Commands Reference

```bash
# Build & Deploy
docker-compose up -d              # Start all services
docker-compose up -d --build      # Rebuild & start
docker-compose build              # Just build
docker-compose build --no-cache   # Build without cache

# Status & Logs
docker-compose ps                 # Show status
docker-compose logs -f            # Live logs
docker-compose stats              # Resource usage

# Execute Commands
docker-compose exec backend bash  # Shell access
docker-compose exec backend npm run strapi develop
docker-compose exec postgres psql -U strapi_user

# Database
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql

# Cleanup
docker-compose down               # Stop & remove containers  
docker-compose down -v            # Also remove volumes
docker system prune -a            # Remove unused images/volumes
```

---

## 🆘 Get Help

### Logs & Debugging

```bash
# Capture full logs
docker-compose logs > debug.log 2>&1

# Specific service with timestamps
docker-compose logs --timestamps backend | tail -100

# Export for analysis
docker-compose logs > logs.txt
```

### Issues Checklist

1. ❓ Is Docker running?
   ```bash
   docker ps
   ```

2. ❓ Are all containers healthy?
   ```bash
   docker-compose ps
   ```

3. ❓ Check database?
   ```bash
   docker-compose exec postgres pg_isready
   ```

4. ❓ Check logs?
   ```bash
   docker-compose logs backend
   ```

5. ❓ Port available?
   ```bash
   netstat -tulpn | grep 80
   netstat -tulpn | grep 443
   ```

---

## 📞 Support Resources

- **Strapi Docs:** https://docs.strapi.io
- **Next.js Docs:** https://nextjs.org/docs
- **Docker Docs:** https://docs.docker.com
- **Let's Encrypt:** https://letsencrypt.org
- **Nginx Docs:** https://nginx.org/en/docs

---

## 📋 Checklists

### Before Going Live ✅

- [ ] Database password changed (32+ chars)
- [ ] All secrets generated (APP_KEYS, etc.)
- [ ] Domain pointed to VPS
- [ ] SSL certificate installed
- [ ] Nginx config updated with domain
- [ ] Health check passing
- [ ] Backup script setup
- [ ] Monitoring dashboard setup
- [ ] Email alerts configured

### Monthly Maintenance ✅

- [ ] Check disk space: `df -h`
- [ ] Review logs for errors
- [ ] Update Docker images: `docker-compose pull`
- [ ] Database backup successful
- [ ] SSL cert expiry check: `certbot certificates`
- [ ] Security updates: `apt update && apt upgrade`

### Monitoring ✅

```bash
# Run health check
./health-check.sh

# View metrics
docker stats

# Check certificate expiry
certbot certificates
```

---

## 🎓 Learning Resources

### Docker Concepts
- Containers vs VMs
- Images & Layers
- Docker Compose orchestration
- Volumes for persistence
- Networks for communication

### Next.js
- Server Components
- App Router
- ISR (Incremental Static Regeneration)
- API Routes
- Environment Variables

### Strapi
- Content Types
- Plugins
- Webhooks
- Docker deployment
- Database migrations

---

## 📝 Notes

- **Development:** Use `docker-compose logs -f` cho debugging
- **Production:** Enable health monitoring: `./health-check.sh`
- **Backup:** Backup database weekly: `docker-compose exec postgres pg_dump...`
- **Updates:** Test code changes locally first before deploying
- **Security:** Never commit `.env` files with secrets

---

**Created:** 2024  
**Updated:** March 2026  
**Version:** 1.0

---

## English Version

[Complete English guide in DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
