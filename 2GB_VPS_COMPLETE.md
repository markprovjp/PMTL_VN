# ✅ 2GB VPS Optimization Complete

## 📦 Files Created for 2GB VPS Support

### 🎯 Main Files to Use

| File | Purpose | Use When |
|------|---------|----------|
| **2GB_VPS_SETUP.md** | 👈 START HERE | First time deployment |
| **deploy-2gb.sh** | Smart deployment | Deploy to 2GB VPS |
| **2GB_OPTIONS_COMPARISON.md** | Decision guide | Choose Meilisearch option |
| **OPTIMIZATION_2GB_VPS.md** | Detailed guide | Deep dive into options |

### 🔧 Configuration Files

| File | Purpose |
|------|---------|
| **.env.2gb** | Environment template for 2GB |
| **docker-compose.prod.2gb.yml** | If using local Meilisearch (Option C) |
| **BE_PMTL/Dockerfile.2gb** | Optimized backend build |
| **fe-pmtl/Dockerfile.2gb** | Optimized frontend build |

### 📊 Reference Files

| File | Purpose |
|------|---------|
| **RAM_ANALYSIS.md** | Memory breakdown analysis |
| **QUICK_REFERENCE.md** | Command cheat sheet (existing) |
| **DEPLOYMENT_GUIDE.md** | Full deployment guide (existing) |
| **SETUP_GUIDE.md** | General setup guide (existing) |

---

## 🚀 Quick Start (5 min)

```bash
# 1. SSH to VPS
ssh root@your-vps-ip

# 2. Clone project
git clone <your-repo> /apps/pmtl-vn
cd /apps/pmtl-vn

# 3. Run smart deploy
chmod +x deploy-2gb.sh
./deploy-2gb.sh

# 4. Choose option when prompted
# A = Meilisearch Cloud (RECOMMENDED ⭐)
# B = Disable Meilisearch
# C = Keep Local (risky)

# 5. Follow prompts - DONE! 🎉
```

---

## 🎯 Choose Your Path

### Path 1: Meilisearch Cloud ☁️ (RECOMMENDED)

**Best for:** Most users, safety, performance

```bash
./deploy-2gb.sh
# Answer: A
# (Need Meilisearch Cloud account - free tier works)
```

**Result:** 
- ✅ 1.1GB RAM used (safe!)
- ✅ Full search features
- ✅ No monitoring needed
- ✅ Free for 100K documents

**Files involved:**
- `deploy-2gb.sh` (handles it all)
- `.env.2gb` (template)
- Regular `docker-compose.yml`

---

### Path 2: Disable Meilisearch ⚡ (QUICK)

**Best for:** Budget, simplicity, basic needs

```bash
./deploy-2gb.sh
# Answer: B
# Scripts removes Meilisearch automatically
```

**Result:**
- ✅ 1.1GB RAM used (safe!)
- ✅ Basic search still works
- ✅ Zero maintenance
- ✅ Free forever

**Files involved:**
- `deploy-2gb.sh` (handles it all)
- `.env.2gb` (template)
- Regular `docker-compose.yml`

---

### Path 3: Keep Local Meilisearch 🔧 (RISKY)

**Best for:** Power users, local-only preference

```bash
# First setup swap (REQUIRED!)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Then deploy
./deploy-2gb.sh
# Answer: C
```

**Result:**
- ⚠️ 1.8GB RAM used (tight!)
- ⚠️ All features local
- ⚠️ Need constant monitoring
- ⚠️ Risk of slowness/crashes

**Files involved:**
- `deploy-2gb.sh` (handles setup)
- `.env.2gb` (template)
- `docker-compose.prod.2gb.yml` (memory limits)
- `BE_PMTL/Dockerfile.2gb`
- `fe-pmtl/Dockerfile.2gb`

---

## 💡 What's Inside Each File

### deploy-2gb.sh

Interactive script that:
1. ✅ Checks Docker installation
2. ✅ Shows Meilisearch options (A, B, or C)
3. ✅ Configures environment
4. ✅ Builds Docker images
5. ✅ Starts all services
6. ✅ Shows status & next steps

**Handles all the complexity for you!**

---

### .env.2gb

Template with:
- Database config (tight limits)
- Backend/frontend settings
- Meilisearch placeholders (Option A)
- 2GB-specific optimizations
- Comments explaining each setting

**Copy to .env and customize with your values**

---

### docker-compose.prod.2gb.yml

Optimized Docker Compose with:
- Memory limits on all containers:
  - Strapi: 384MB (from unlimited)
  - Next.js: 256MB (from unlimited)
  - PostgreSQL: 256MB (from unlimited)
  - Nginx: 64MB (from unlimited)
- Optimized database config
- Optional commented Meilisearch

**Used only for Option C (local Meilisearch)**

---

### BE_PMTL/Dockerfile.2gb & fe-pmtl/Dockerfile.2gb

Optimized Dockerfiles with:
- Node memory limits built-in
- `--max-old-space-size=384` (backend)
- `--max-old-space-size=256` (frontend)
- Multi-stage builds (minimal images)
- Health checks

**Used only for Option C (local Meilisearch)**

---

## 📊 RAM Usage by Option

### Option A (Cloud) - RECOMMENDED ☁️

```
Your VPS: 2GB
Used: ~1.1GB
Safe Margin: ~900MB ✅

Breakdown:
- Strapi:      350MB
- Next.js:     250MB  
- PostgreSQL:  300MB
- Nginx:       50MB
- System:      350MB
- Meilisearch: CLOUD (0MB)
```

### Option B (Disabled) ⚡

```
Your VPS: 2GB
Used: ~1.1GB
Safe Margin: ~900MB ✅

Breakdown:
- Strapi:      350MB
- Next.js:     250MB
- PostgreSQL:  300MB
- Nginx:       50MB
- System:      350MB
- Meilisearch: NONE (0MB)
```

### Option C (Local) 🔧

```
Your VPS: 2GB
Used: ~1.8GB
Safe Margin: ~200MB ⚠️

Breakdown:
- Strapi:      350MB
- Next.js:     250MB
- PostgreSQL:  300MB
- Nginx:       50MB
- Meilisearch: 700MB 🔴
- System:      350MB

WITH 2GB SWAP:
Total Available: 4GB
Can handle spikes
BUT: Swap = slower
```

---

## 🔄 How to Migrate Between Options

### Cloud → Disabled
```bash
# Edit .env
nano .env
# Remove/comment:
# MEILISEARCH_HOST=...
# MEILISEARCH_API_KEY=...

# Restart
docker-compose restart backend
```

### Disabled → Cloud
```bash
# Edit .env with Cloud credentials
nano .env
# Add:
MEILISEARCH_HOST=https://...
MEILISEARCH_API_KEY=...

# Restart
docker-compose restart backend
```

### Cloud/Disabled → Local (NOT RECOMMENDED)
```bash
# Would need to stop, rebuild with .2gb files
# Better to just upgrade VPS instead
```

---

## 📋 Deployment Checklist

### Before Running deploy-2gb.sh

- [ ] SSH access to VPS
- [ ] Docker installed (or script installs it)
- [ ] Project cloned
- [ ] Passwords prepared (strong 32+ chars)
- [ ] Domain ready (DNS pointing to VPS)
- [ ] If Option C: 2GB swap created first

### During deploy-2gb.sh

- [ ] Choose option (A/B/C)
- [ ] Edit .env with your secrets
- [ ] Docker images build
- [ ] Containers start
- [ ] Health checks pass

### After deploy-2gb.sh

- [ ] Test `docker-compose ps` (all running)
- [ ] Check `free -h` (memory looks good)
- [ ] Visit frontend (http://your-vps-ip)
- [ ] For domain: Update DNS + SSL (see guide)
- [ ] Setup backups (see QUICK_REFERENCE.md)

---

## 📖 Documentation Map

```
Start Your Journey Here ↓

2GB_VPS_SETUP.md ⭐ [Main guide]
    ↓
    ├─→ For command help:
    │   QUICK_REFERENCE.md
    │
    ├─→ For decision help:
    │   2GB_OPTIONS_COMPARISON.md
    │
    ├─→ For deep dive:
    │   OPTIMIZATION_2GB_VPS.md
    │
    ├─→ For general Docker info:
    │   DEPLOYMENT_GUIDE.md
    │
    └─→ For monitoring memory:
        RAM_ANALYSIS.md
```

---

## 🎯 Success Criteria

You've succeeded when:

✅ `docker-compose ps` shows all running  
✅ `free -h` shows ~1.1-1.3GB used (not 1.8GB+)  
✅ `./health-check.sh` passes  
✅ Frontend loads in browser  
✅ No "Out of Memory" errors in logs  
✅ Domain working with HTTPS  

---

## 🆘 Troubleshooting Map

| Problem | Check This | File |
|---------|-----------|------|
| High RAM usage | RAM_ANALYSIS.md | Memory breakdown |
| Docker won't build | Check dockerfile | Dockerfile.2gb |
| Services keep crashing | Check memory limits | docker-compose.prod.2gb.yml |
| Meilisearch issues | 2GB_OPTIONS_COMPARISON.md | Option details |
| Command questions | Quick reference | QUICK_REFERENCE.md |
| General setup help | 2GB_VPS_SETUP.md | Quick steps |

---

## 🚀 Next Steps

### Immediate (Do Now)

1. Read: **2GB_VPS_SETUP.md** (15 min)
2. Run: `./deploy-2gb.sh` (5-10 min)
3. Check: `docker-compose ps` (30 sec)

### Short-term (Day 1)

1. Setup domain & SSL (15 min)
2. Create first backup (5 min)
3. Monitor memory (ongoing)

### Ongoing

1. Weekly backups
2. Monthly monitoring
3. Check for updates

---

## 💬 Common Questions Answered

### "Will it really fit in 2GB?"
✅ YES with Option A or B
⚠️ MAYBE with Option C (need swap)

### "What if I pick wrong option?"
✅ Easy to switch! Just edit .env and restart

### "Can I upgrade later?"
✅ YES, just upgrade VPS and switch to local Meilisearch

### "Will it be slow?"
✅ Option A & B: No (1.1GB is safe)
⚠️ Option C: Possible slowness with swap

### "How do I backup?"
✅ See QUICK_REFERENCE.md - one command backup

### "What's Meilisearch Cloud cost?"
✅ FREE (100K docs) → $15/mo (1M+ docs)

---

## 🎁 Bonus Features Included

- ✅ Automated deployment script
- ✅ Optimized Docker configs
- ✅ Health monitoring
- ✅ Backup templates
- ✅ SSL/HTTPS ready
- ✅ Environment templates
- ✅ Decision guides
- ✅ Memory analysis

---

## 📞 Need Help?

1. **First:** Read 2GB_VPS_SETUP.md
2. **Then:** Check 2GB_OPTIONS_COMPARISON.md
3. **Finally:** Search OPTIMIZATION_2GB_VPS.md for your issue

All documentation is written for 2GB VPS specifically! 

---

## ✨ Final Tip

**Recommended: Use Option A (Cloud)** ☁️

Just run:
```bash
./deploy-2gb.sh
# Answer: A
```

Takes 10 minutes, zero worries, maximum comfort! 🎉

---

**Status:** ✅ 2GB VPS Ready  
**Version:** 1.0  
**Created:** 2024  
**Updated:** March 2026

**Good luck with your deployment!** 🚀
