# PMTL_VN - Quick Reference Card

## 🚀 Start/Stop

| Task | Command |
|------|---------|
| **Start all** | `docker-compose up -d` |
| **Stop all** | `docker-compose down` |
| **Restart all** | `docker-compose restart` |
| **Restart service** | `docker-compose restart backend` |
| **View status** | `docker-compose ps` |

## 📋 Logs

| Task | Command |
|------|---------|
| **All logs live** | `docker-compose logs -f` |
| **Backend logs** | `docker-compose logs -f backend` |
| **Frontend logs** | `docker-compose logs -f frontend` |
| **Nginx logs** | `docker-compose logs -f nginx` |
| **Last 100 lines** | `docker-compose logs --tail 100 backend` |
| **Save to file** | `docker-compose logs > logs.txt` |

## 🔧 Deploy

| Scenario | Command |
|----------|---------|
| **Development** | `cp .env.dev .env` then `docker-compose up -d` |
| **Production (Linux)** | `./deploy.sh prod` |
| **Production (Windows)** | `deploy.bat prod` |
| **Rebuild & restart** | `docker-compose up -d --build` |
| **No cache rebuild** | `docker-compose build --no-cache` |

## 🗄️ Database

| Task | Command |
|------|---------|
| **Backup** | `docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql` |
| **Backup compressed** | `docker-compose exec postgres pg_dump -U strapi_user strapi_db \| gzip > backup.sql.gz` |
| **Restore** | `docker-compose exec -T postgres psql -U strapi_user strapi_db < backup.sql` |
| **Access DB** | `docker-compose exec postgres psql -U strapi_user -d strapi_db` |
| **List tables** | Within psql: `\dt` |
| **Quit psql** | `\q` |

## 🌐 Access

| Service | Local | Production |
|---------|-------|------------|
| **Frontend** | http://localhost | https://yourdomain.com |
| **API** | http://localhost/api | https://yourdomain.com/api |
| **Admin** | http://localhost/admin | https://yourdomain.com/admin |
| **Database** | localhost:5432 | NOT exposed |

## 🔐 Secrets & Environment

| Task | Command |
|------|---------|
| **Generate new keys** | `node -e "console.log(require('crypto').randomBytes(16).toString('base64'))"` |
| **View env vars** | `docker-compose exec backend env \| grep DATABASE` |
| **Edit environment** | `nano .env` or edit in editor |
| **Reload env** | `docker-compose restart backend` |

## 🏥 Health Check

| Task | Command |
|------|---------|
| **Quick health check** | `./health-check.sh` |
| **Check specific service** | `docker-compose exec backend curl http://localhost:1337/admin` |
| **Check database** | `docker-compose exec postgres pg_isready` |
| **Check disk** | `df -h` |

## 📦 Updates

| Task | Command |
|------|---------|
| **Pull latest code** | `git pull origin main` |
| **Update images** | `docker-compose pull` |
| **Rebuild** | `docker-compose build` |
| **Apply changes** | `docker-compose up -d` |

## 🧹 Cleanup

| Task | Command |
|------|---------|
| **Stop & remove** | `docker-compose down` |
| **Remove volumes too** | `docker-compose down -v` |
| **Clean Docker** | `docker system prune -a` |
| **Clean build cache** | `docker builder prune -a` |
| **Check disk usage** | `du -sh /var/lib/docker` |

## 🆘 Troubleshooting

```bash
# Backend issue?
docker-compose logs backend

# Frontend issue?
docker-compose logs frontend

# Database issue?
docker-compose logs postgres
docker-compose exec postgres pg_isready

# Nginx issue?
docker-compose exec nginx nginx -t
docker-compose logs nginx

# Port in use?
lsof -i :80
lsof -i :443

# Out of space?
df -h
docker system prune -a --volumes

# Service unhealthy?
docker-compose restart [service]
```

## 📲 Shell Access

```bash
# Backend shell
docker-compose exec backend bash

# Frontend shell
docker-compose exec frontend bash

# Database shell
docker-compose exec postgres psql -U strapi_user -d strapi_db

# Nginx shell
docker-compose exec nginx sh
```

## 🔒 SSL/Domain Setup

```bash
# 1. Point DNS A record to VPS IP

# 2. Get certificate
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# 3. Update nginx/conf.d/default.conf with domain

# 4. Restart Nginx
docker-compose restart nginx

# 5. Test
curl https://yourdomain.com

# 6. Check expiry
certbot certificates

# 7. Auto renew (daily)
certbot renew --dry-run
```

## 💡 Pro Tips

```bash
# Watch real-time stats
watch docker stats

# Follow logs with timestamps
docker-compose logs -f --timestamps backend

# Get just error lines
docker-compose logs backend 2>&1 | grep ERROR

# Count container lines
docker-compose ps | wc -l

# Get IP of service
docker inspect pmtl-backend | grep IPAddress

# Run one-off command
docker-compose exec -T backend npm run strapi migrate latest

# Backup before major update
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup-before-update.sql
```

## 📌 Files You'll Edit Often

| File | Purpose |
|------|---------|
| `.env` | Environment variables (DON'T COMMIT) |
| `docker-compose.yml` | Service definitions |
| `nginx/conf.d/default.conf` | Domain, SSL, routing |
| `BE_PMTL/config/database.ts` | DB connection pool |
| `fe-pmtl/next.config.mjs` | Frontend configuration |

## 🚨 Never Do This

❌ `docker-compose down -v` on production (deletes database!)  
❌ Commit `.env` with secrets  
❌ Use weak DATABASE_PASSWORD  
❌ Ignore health check warnings  
❌ Skip database backups  
❌ Run containers as root  
❌ Expose DB to internet  

## ✅ Always Do This

✅ Backup database weekly  
✅ Check health daily  
✅ Update security patches  
✅ Monitor logs  
✅ Test changes locally first  
✅ Keep secrets secure  
✅ Document changes  
✅ Enable SSL/HTTPS  

---

**Version:** 1.0  
**Last Updated:** March 2026
