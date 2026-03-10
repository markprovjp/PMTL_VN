# 🎯 PMTL_VN on 2GB VPS - Complete Setup Guide

## Quick Answer: YES, It Works! ✅

**But with a catch:** You need to handle **Meilisearch** (search feature).

---

## 📊 Memory Breakdown

```
Your VPS: 2GB RAM

WITHOUT Meilisearch:  ~1.1GB  ✅ Safe
WITH local Meilisearch: ~1.8GB ⚠️ Tight (needs swap)
WITH Meilisearch Cloud: ~1.1GB ✅ Perfect
```

---

## 🎯 Recommended Solution (BEST)

### Use Meilisearch Cloud ⭐

**Why?** 
- ✅ Same search capability
- ✅ Saves 700MB RAM
- ✅ FREE tier (100K documents)
- ✅ Better performance
- ✅ No maintenance

**Steps:**

1. **Sign up at Meilisearch Cloud** (2 min)
   - https://cloud.meilisearch.com
   - Create free account
   - Get API key

2. **Run deploy script** (5 min)
   ```bash
   chmod +x deploy-2gb.sh
   ./deploy-2gb.sh
   # Choose: A (Cloud)
   # Enter your Meilisearch Cloud credentials
   ```

3. **Done!** ✅
   - All services running
   - Memory safe
   - Search working

---

## 🚀 Full Deployment (Meilisearch Cloud)

### Prerequisites

```bash
# SSH to VPS
ssh root@your-vps-ip

# Install Docker (if needed)
curl -sSL https://get.docker.com | sh
```

### Deploy in 5 Steps

#### Step 1: Clone & Setup

```bash
mkdir -p /apps && cd /apps
git clone <your-repo-url> pmtl-vn
cd pmtl-vn
```

#### Step 2: Run Smart Deploy Script

```bash
chmod +x deploy-2gb.sh
./deploy-2gb.sh
```

**Script will:**
- ✅ Ask about Meilisearch options
- ✅ Setup environment
- ✅ Build Docker images
- ✅ Start containers
- ✅ Show status

#### Step 3: Choose Option A (Cloud)

```
Choose [A/B/C]: A

(opens browser to Meilisearch Cloud setup)
Enter Meilisearch Instance URL: https://your-xxx.meilisearch.com
Enter Meilisearch API Key: your-secret-key
```

#### Step 4: Configure .env

Script automatically edits `.env` with your values. Then edit remaining:

```bash
nano .env
```

Update:
- `DATABASE_PASSWORD` → strong password
- `NEXT_PUBLIC_API_URL` → https://yourdomain.com/api
- `NEXT_PUBLIC_SITE_URL` → https://yourdomain.com
- All `APP_KEYS`, `JWT_SECRET`, etc.

#### Step 5: Deploy Domain & SSL

```bash
# Update DNS A records to your VPS IP
# yourdomain.com → YOUR_VPS_IP
# www.yourdomain.com → YOUR_VPS_IP

# Enable SSL in Nginx config
nano nginx/conf.d/default.conf
# Uncomment HTTPS section

# Get certificate
apt install certbot -y
certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your-email@gmail.com \
  --agree-tos \
  --non-interactive

# Restart Nginx
docker-compose restart nginx
```

---

## 📈 What About Future Growth?

### If documents grow > 100K

Meilisearch Cloud has paid tiers:
- 100K docs: FREE ✅
- 1M docs: $15/month
- Unlimited: $49/month

Or upgrade VPS and use local Meilisearch:
```bash
# Upgrade VPS to 4GB
# Use regular docker-compose.yml
# No code changes needed
```

---

## 🔍 Alternative Options (Choose One)

### Option B: Disable Meilisearch

**If you don't need advanced search:**

```bash
./deploy-2gb.sh
# Choose: B (Disable)
```

**Result:**
- RAM: 1.1GB (very safe)
- Search: PostgreSQL basic search
- Cost: $0
- Setup: 5 min

---

### Option C: Keep Local Meilisearch (Risky)

**Only if you want everything local:**

```bash
./deploy-2gb.sh
# Choose: C (Local)
```

**Requirements:**
- ⚠️ Need 2GB+ swap
- ⚠️ Constant monitoring
- ⚠️ Risk of OOM kills
- ⚠️ Slow under high load

**Setup swap first:**
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## ✅ Plugins Analysis

Your current plugins:

| Plugin | RAM | Status | 2GB OK? |
|--------|-----|--------|---------|
| CKEditor 5 | 20MB | ✅ Keep | Yes |
| Users-Permissions | 30MB | ✅ Keep | Yes |
| Documentation | 5MB | ✅ Keep | Yes |
| Cloud | 5MB | ⚠️ Optional | Yes |
| **Meilisearch** | **700MB** | 🔴 **FIX** | **NO** |

**For 2GB: Remove Meilisearch locally, use Cloud** ✅

---

## 🎁 What You Get

### Memory Efficient ✅
```
Strapi Backend:    350MB
Next.js Frontend:  250MB
PostgreSQL:        300MB
Nginx:             50MB
Meilisearch:       CLOUD (0MB)
─────────────────────────
Total:             950MB + 350MB system
                   ≈ 1.3GB SAFE! ✅
```

### Production Ready ✅
- SSL/HTTPS support
- Automatic restarts
- Health monitoring
- Database backups
- Nginx caching
- Rate limiting

### Easy to Manage ✅
- One-command deploy
- Simple monitoring
- Backup scripts
- Clear logs

---

## 📋 Deployment Checklist

- [ ] Docker installed on VPS
- [ ] Project cloned
- [ ] `deploy-2gb.sh` ready
- [ ] **Meilisearch Cloud account** (if using Option A)
- [ ] Domain DNS pointing to VPS
- [ ] Strong passwords generated
- [ ] `.env` file filled with secrets

### Deploy

- [ ] Run `./deploy-2gb.sh`
- [ ] Choose option (A recommended)
- [ ] All containers running? `docker-compose ps`
- [ ] Health check pass? `./health-check.sh`
- [ ] Memory OK? `free -h` (should be < 1.5GB)
- [ ] Frontend loads? Visit http://your-vps-ip
- [ ] Domain works? Update Nginx + SSL
- [ ] Backups working? Test DB backup

---

## 🔒 Security Setup (After Deploy)

```bash
# 1. Firewall
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

# 2. SSH hardening
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 3. Auto updates
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades

# 4. Monitoring
crontab -e
# Add: */5 * * * * ./health-check.sh >> /var/log/pmtl-check.log 2>&1
```

---

## 📊 Monitoring (After Deploy)

### Daily

```bash
# Check memory
free -h

# Check containers
docker-compose ps

# View logs
docker-compose logs --tail 50
```

### Weekly

```bash
# Full health check
./health-check.sh

# Backup database
docker-compose exec postgres pg_dump -U strapi_user strapi_db | gzip > backup-$(date +%Y%m%d).sql.gz
```

### Monthly

```bash
# Check certificate expiry
certbot certificates

# Update system
apt update && apt upgrade -y

# Docker cleanup
docker system prune -a --volumes
```

---

## 🆘 Troubleshooting

### "High RAM usage"
```bash
# Check which container
docker stats

# If Meilisearch high:
# → Should be cloud only, not local!
# → Check docker-compose.yml

# If backend high:
# → Might be memory leak
# → Restart: docker-compose restart backend
```

### "Out of Memory" crash
```bash
# Check logs
docker-compose logs

# If it's swap issue:
# → Need more VPS memory
# → Or switch to cloud Meilisearch

dmesg | grep -i killed  # Check system
```

### "Slow response times"
```bash
# Check if using swap
grep SwapCached /proc/meminfo

# If yes and > 100MB:
# → VPS is struggling
# → Upgrade or optimize further
```

### "Services won't start"
```bash
# Check logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 💡 Pro Tips for 2GB VPS

1. **Monitor regularly**
   ```bash
   watch -n 5 free -h
   ```

2. **Keep backups**
   ```bash
   # Weekly backup script
   0 2 * * 0 docker-compose exec postgres pg_dump -U strapi_user strapi_db | gzip > backup-$(date +\%Y\%m\%d).sql.gz
   ```

3. **Clean up old logs** (once a month)
   ```bash
   # Docker logs clean
   docker system prune -a --volumes
   
   # Old backups
   find . -name "backup-*.sql.gz" -mtime +30 -delete
   ```

4. **Use Meilisearch Cloud for scale**
   - Free tier grows to 100K documents
   - Paid tier for more
   - No performance hit locally

5. **Monitor swap usage**
   ```bash
   # If swap > 20% in use, consider:
   # - Upgrade VPS
   # - Reduce app memory allocation
   # - Use cloud services more
   ```

---

## 📈 Growth Path

### If you grow:

```
2GB (Meilisearch Cloud) ← YOU ARE HERE [SAFE ✅]
        ↓ (1M documents)
4GB (Local Meilisearch) [Performance]
        ↓ (Heavy traffic)
8GB+ (Clustered setup) [Scale]
```

Just upgrade VPS when needed, no code changes!

---

## 📞 File Reference

| File | Use Case |
|------|----------|
| `deploy-2gb.sh` | Smart deploy for 2GB |
| `docker-compose.prod.2gb.yml` | If you choose Option C |
| `.env.2gb` | Template for 2GB config |
| `OPTIMIZATION_2GB_VPS.md` | Detailed optimization guide |
| `health-check.sh` | Monitor health |
| `QUICK_REFERENCE.md` | Command reference |

---

## ✨ Bottom Line

**For 2GB VPS with PMTL_VN:**

```bash
✅ Use Meilisearch Cloud (FREE tier)
✅ Memory safe (~1.1GB)
✅ Great performance
✅ Easy setup (5 min)
✅ Future scalable

./deploy-2gb.sh  # One script handles it all!
```

**That's it!** 🚀

---

**Status:** Ready for 2GB VPS  
**Version:** 1.0  
**Created:** 2024  
**Updated:** March 2026

📖 **Next:** Read [OPTIMIZATION_2GB_VPS.md](./OPTIMIZATION_2GB_VPS.md) for details
