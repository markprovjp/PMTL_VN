# Docker & Deployment Setup untuk PMTL_VN

Hướng dẫn setup Docker cho project PMTL_VN (Strapi + Next.js)

## 📋 Nội dung

- [Quick Start](#quick-start)
- [Cấu trúc Docker](#cấu-trúc-docker)
- [Deployment lên VPS](#deployment-lên-vps)
- [Quản lý Services](#quản-lý-services)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Development (Máy Local)

```bash
# 1. Copy environment dev
cp .env.dev .env

# 2. Start containers
docker-compose up -d

# 3. Kiểm tra services
docker-compose ps

# 4. Xem logs
docker-compose logs -f

# 5. Truy cập
# Frontend: http://localhost
# API: http://localhost/api
# Admin: http://localhost/admin
```

### Production (VPS)

```bash
# 1. SSH vào VPS
ssh root@your-vps-ip

# 2. Setup Docker (nếu chưa có)
curl -sSL https://get.docker.com | sh

# 3. Clone project
git clone <repo-url> /apps/pmtl-vn
cd /apps/pmtl-vn

# 4. Copy production env
cp .env.production .env

# 5. Edit secrets
nano .env  # Update các keys, passwords, domain

# 6. Deploy
./deploy.sh prod
# hoặc Windows: deploy.bat prod
```

---

## 🏗️ Cấu trúc Docker

### Services

```
┌─────────────────────────────────┐
│         Nginx (Port 80, 443)    │  ← Reverse Proxy, Static, SSL
├─────────────────────────────────┤
│  ┌──────────────┬──────────────┐│
│  │  Frontend    │   Backend    ││
│  │  (Next.js)   │  (Strapi)    ││
│  │  Port 3000   │  Port 1337   ││
│  └──────────────┴──────────────┘│
├─────────────────────────────────┤
│    PostgreSQL (Port 5432)       │  ← Database
└─────────────────────────────────┘
```

### Files

| File | Mục đích |
|------|---------|
| `docker-compose.yml` | Chính - Config tất cả services |
| `BE_PMTL/Dockerfile` | Build image Backend |
| `fe-pmtl/Dockerfile` | Build image Frontend |
| `nginx/nginx.conf` | Nginx main config |
| `nginx/conf.d/default.conf` | Nginx virtual hosts |
| `.env.dev` | Environment cho development |
| `.env.production` | Environment cho production |
| `deploy.sh` | Script deploy Linux/Mac |
| `deploy.bat` | Script deploy Windows |

---

## 🔧 Quản lý Services

### Xem Status

```bash
# Tất cả services
docker-compose ps

# Chi tiết
docker-compose ps -a

# Resource usage
docker stats
```

### Logs

```bash
# Tất cả
docker-compose logs -f

# Theo service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx
docker-compose logs -f postgres

# Một số dòng cuối
docker-compose logs --tail 50 backend

# Lưu ra file
docker-compose logs > logs.txt
```

### Start/Stop

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Restart service cụ thể
docker-compose restart backend
```

### Rebuild

```bash
# Rebuild image
docker-compose build

# Rebuild và start
docker-compose up -d --build

# Rebuild service cụ thể
docker-compose build --no-cache backend
```

---

## 🗄️ Database

### Backup

```bash
# Backup to file
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql

# Backup compressed
docker-compose exec postgres pg_dump -U strapi_user strapi_db | gzip > backup.sql.gz
```

### Restore

```bash
# Restore from file
docker-compose exec -T postgres psql -U strapi_user strapi_db < backup.sql

# Restore compressed
gunzip -c backup.sql.gz | docker-compose exec -T postgres psql -U strapi_user strapi_db
```

### Access Database

```bash
# Connect psql
docker-compose exec postgres psql -U strapi_user -d strapi_db

# List databases
docker-compose exec postgres psql -U strapi_user -l

# Commands:
# \dt          - Show tables
# \du          - Show users
# \q           - Quit
```

---

## 🌐 Domain & SSL

### Setup Domain

1. Point DNS A record to VPS IP:
```
A Record: yourdomain.com -> YOUR_VPS_IP
A Record: www.yourdomain.com -> YOUR_VPS_IP
```

2. Update `.env`:
```bash
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

3. Update Nginx config (`nginx/conf.d/default.conf`):
```bash
# Uncomment HTTPS section
# Replace yourdomain.com with your domain
docker-compose restart nginx
```

### SSL Certificate (Let's Encrypt)

```bash
# Install certbot
apt install certbot python3-certbot-nginx -y

# Get certificate
certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  -m your-email@example.com \
  --agree-tos --non-interactive

# Auto-renewal test
certbot renew --dry-run

# Check certificate
certbot certificates
```

---

## 🚨 Troubleshooting

### Backend không start

```bash
# Check logs
docker-compose logs backend

# Verify database
docker-compose exec postgres psql -U strapi_user -d strapi_db -c "SELECT 1"

# Check env
docker-compose exec backend env | grep DATABASE
```

### Frontend error

```bash
# Logs
docker-compose logs frontend

# Test API
docker-compose exec frontend curl http://backend:1337/api
```

### Nginx error

```bash
# Logs
docker-compose logs nginx

# Test config
docker-compose exec nginx nginx -t

# Reload config
docker-compose exec nginx nginx -s reload
```

### Hết dung lượng disk

```bash
# Check
df -h

# Clean up Docker
docker system prune -a --volumes

# Clean build cache
docker builder prune -a
```

### Port bị chiếm

```bash
# Tìm process
lsof -i :80  # Port 80
lsof -i :443 # Port 443

# Kill process
kill -9 <PID>

# Hoặc change port trong docker-compose.yml
```

---

## 📊 Performance

### Nginx Caching
- Static assets: 7 days
- API responses: không cache
- Compression: gzip enabled

### Database Connection Pool
Tăng connection pool nếu cần:
```typescript
// BE_PMTL/config/database.ts
pool: { 
  min: 5,    // từ 2
  max: 20    // từ 10
}
```

### Next.js Optimization
```typescript
// app/layout.tsx hoặc route
export const revalidate = 3600; // ISR - 1 hour
```

---

## 🔒 Security

✅ **Đã setup:**
- Non-root users dalam container
- Health checks
- Network isolation
- Restart policies

❌ **Cần làm:**

```bash
# 1. Update mật khẩu .env
NEXT_PUBLIC_API_URL=https://yourdomain.com/api

# 2. SSH key auth (disable password)
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 3. Firewall
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

# 4. Auto updates
apt install unattended-upgrades
```

---

## 📞 Commands Cheat Sheet

```bash
# Build & Deploy
docker-compose up -d              # Start all
docker-compose up -d --build      # Rebuild
docker-compose build              # Build only
docker-compose down               # Stop & remove

# Logs & Status
docker-compose ps                 # Status
docker-compose logs -f            # Live logs
docker-compose logs --tail 50     # Last 50 lines

# Exec Commands
docker-compose exec backend bash  # Shell
docker-compose exec backend npm run strapi migrate latest

# Database
docker-compose exec postgres psql -U strapi_user -d strapi_db

# Cleanup
docker-compose down -v            # Stop & delete volumes
docker system prune -a            # Remove unused images
```

---

## 📚 Tài liệu

- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - Chi tiết đầy đủ
- [Strapi Docs](https://docs.strapi.io)
- [Next.js Docs](https://nextjs.org/docs)
- [Docker Docs](https://docs.docker.com)

---

**Created:** 2024
**Updated:** March 2026
