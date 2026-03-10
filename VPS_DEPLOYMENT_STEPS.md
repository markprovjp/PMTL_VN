# 🚀 VPS DEPLOYMENT GUIDE - For Your 2 Repos

## ✅ VPS Readiness Check

Bạn đã hoàn thành:
- ✅ Docker installed
- ✅ Docker Compose installed  
- ✅ 4GB Swap created
- ✅ Ubuntu 22.04 LTS (Jammy)

**Status:** Ready to deploy! 🎉

---

## 📋 Step-by-Step VPS Setup

### Step 1: Prepare Deployment Scripts

```bash
# On your LOCAL machine (your computer)
# Copy these 2 scripts to the VPS:

# Option A: Using Git (if you have these scripts in repo)
cd /apps/pmtl-vn
git pull origin main

# Option B: Upload files directly
scp vps-setup.sh root@your-vps-ip:/root/
scp setup-domain.sh root@your-vps-ip:/root/
```

---

### Step 2: Run VPS Setup on VPS

```bash
# SSH to VPS
ssh root@your-vps-ip

# Make scripts executable
chmod +x /root/vps-setup.sh
chmod +x /root/setup-domain.sh

# Run main setup
/root/vps-setup.sh
```

**Script will:**
1. Clone PMTL-FE từ: https://github.com/markprovjp/PMTL-FE
2. Clone PMTL-BE từ: https://github.com/markprovjp/PMTL-BE
3. Create docker-compose.yml
4. Create Nginx config
5. Build Docker images
6. Start all containers
7. Show status

---

### Step 3: Configure Environment

```bash
# Still on VPS
cd /apps/pmtl-vn

# Edit environment file
nano .env
```

**Update these values:**

```bash
# Database - CHANGE PASSWORD!
DATABASE_PASSWORD=your_super_strong_password_32_chars_min

# Domain (temporary, update later)
NEXT_PUBLIC_API_URL=http://YOUR_VPS_IP/api
NEXT_PUBLIC_SITE_URL=http://YOUR_VPS_IP

# Strapi Keys - GENERATE NEW!
# Run this to generate:
```

**Generate secure keys:**
```bash
node -e "
const crypto = require('crypto');
console.log('APP_KEYS=' + crypto.randomBytes(16).toString('base64'));
console.log('API_TOKEN_SALT=' + crypto.randomBytes(16).toString('base64'));
console.log('ADMIN_JWT_SECRET=' + crypto.randomBytes(16).toString('base64'));
console.log('JWT_SECRET=' + crypto.randomBytes(16).toString('base64'));
console.log('TRANSFER_TOKEN_SALT=' + crypto.randomBytes(16).toString('base64'));
"
```

Paste outputs vào .env

---

### Step 4: Verify Services

```bash
# Check if all containers running
docker-compose ps

# Should show:
# - pmtl-postgres    (up)
# - pmtl-backend     (up)  
# - pmtl-frontend    (up)
# - pmtl-nginx       (up)

# Check memory usage
free -h

# Should show:
# Mem: ~1.3GB used (if using Meilisearch Cloud)
# Mem: ~1.1GB used (if disabled)
```

---

### Step 5: Test Your Site

```bash
# Get your VPS IP
hostname -I

# Visit in browser:
# http://YOUR_VPS_IP
# http://YOUR_VPS_IP/api
# http://YOUR_VPS_IP/admin
```

**You should see:**
- ✅ Frontend loads
- ✅ API responds (should see Strapi error if no content)
- ✅ Admin panel loads

---

### Step 6: Setup Domain & SSL (Optional but RECOMMENDED)

```bash
# After Step 5 works, setup your domain

# First update your domain's DNS A record:
# yourdomain.com → YOUR_VPS_IP
# Wait 5-30 minutes for DNS to propagate

# Then run:
/root/setup-domain.sh

# Script will:
# 1. Ask for your domain
# 2. Get SSL certificate from Let's Encrypt (FREE)
# 3. Configure Nginx for HTTPS
# 4. Setup auto-renewal
# 5. Test HTTPS
```

---

## 🔧 Troubleshooting

### "Services won't start"

```bash
# Check logs
docker-compose logs

# Rebuild if needed
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Wait 20 seconds then check
docker-compose ps
```

### "High RAM usage"

```bash
# Check breakdown
docker stats

# If Meilisearch memory > 500MB:
# You may want to switch to Cloud version
# Edit: docker-compose.yml, remove Meilisearch service
```

### "Port 80/443 already in use"

```bash
# Find what's using it
sudo lsof -i :80
sudo lsof -i :443

# Kill if not needed
sudo kill -9 <PID>

# Or change port in docker-compose.yml
```

### "Backend not responding"

```bash
# Database might not be ready
docker-compose logs backend

# Wait 30 seconds then try again
docker-compose ps postgres

# Check health
docker-compose exec postgres pg_isready
```

---

## 📊 What to Do Next

### First Day:
- [ ] Verify all 4 containers running
- [ ] Test frontend loads
- [ ] Test API endpoint
- [ ] Create first backup

### Week 1:
- [ ] Setup domain & SSL
- [ ] Create Strapi admin user
- [ ] Add your first content
- [ ] Monitor memory/logs daily

### Ongoing:
- [ ] Weekly backups
- [ ] Monitor memory
- [ ] Check logs for errors
- [ ] Keep system updated

---

## 📋 Useful Commands

### Monitor

```bash
# Real-time status
docker-compose ps

# Memory/CPU usage
docker stats

# Live logs
docker-compose logs -f

# Specific service logs
docker-compose logs -f backend
```

### Backup Database

```bash
# Backup
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup-$(date +%Y%m%d).sql.gz

# Restore
gunzip -c backup-latest.sql.gz | docker-compose exec -T postgres psql -U strapi_user strapi_db
```

### Admin Access

```bash
# Shell into backend
docker-compose exec backend bash

# Shell into database
docker-compose exec postgres psql -U strapi_user -d strapi_db
```

---

## 🔒 Security Checklist

After deployment, do these:

```bash
# 1. Update SSH (disable password auth)
nano /etc/ssh/sshd_config
# Change: PasswordAuthentication yes → no
systemctl restart sshd

# 2. Enable firewall
ufw allow 22
ufw allow 80  
ufw allow 443
ufw enable

# 3. Setup auto-updates
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades

# 4. Check certificate auto-renewal
crontab -l
# Should show: 0 2 * * * ... (renewal task)
```

---

## 📞 Quick Command Reference

```bash
# Start all
docker-compose up -d

# Stop all
docker-compose down

# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend

# View all logs
docker-compose logs

# Follow logs real-time
docker-compose logs -f

# Check health
./health-check.sh

# Database backup
docker-compose exec postgres pg_dump -U strapi_user strapi_db > backup.sql

# Memory check
free -h

# Update code
cd /apps/pmtl-vn && git pull && docker-compose restart backend
```

---

## 🎯 Success Criteria

You're done when:
- ✅ All 4 containers running (docker-compose ps)
- ✅ Memory < 1.5GB (free -h)
- ✅ Frontend loads (http://YOUR_IP)
- ✅ API responds (http://YOUR_IP/api) 
- ✅ Domain working with HTTPS (if configured)
- ✅ No error logs (docker-compose logs)

---

## 📞 Support

If anything wrong:

1. Check logs: `docker-compose logs`
2. Verify memory: `free -h` 
3. Check containers: `docker-compose ps`
4. Read docs: See files in /apps/pmtl-vn/

---

## 🚀 That's It!

Your PMTL-VN is now running on VPS! 

Next: Monitor it daily and enjoy! 🎉

---

**Created:** March 2026  
**For:** 2GB VPS with Strapi + Next.js + PostgreSQL
