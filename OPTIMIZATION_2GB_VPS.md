# 🚀 PMTL_VN - Optimization Guide for 2GB VPS

## 📊 Problem Summary

Your VPS has **2GB RAM**. Let's see if PMTL_VN fits:

| Service | Min | Typical | Max |
|---------|-----|---------|-----|
| Strapi (Backend) | 250MB | 350MB | 500MB |
| Next.js (Frontend) | 150MB | 250MB | 400MB |
| PostgreSQL | 150MB | 300MB | 500MB |
| **Meilisearch** 🔴 | 300MB | 700MB | 1200MB |
| Other (Nginx, System) | 300MB | 400MB | 600MB |
| **TOTAL** | 1150MB | **2050MB** | 3200MB |

**Issue:** Meilisearch eats 700MB-1GB! 🔴

---

## ✅ Solution: Choose One

### OPTION A: Meilisearch Cloud (RECOMMENDED ⭐)

**Best:** Works perfectly, super fast, free tier available  
**Cost:** FREE (up to 100K documents)  
**Setup Time:** 10 minutes

#### Steps:

1. **Sign up at Meilisearch Cloud:**
   ```
   https://cloud.meilisearch.com
   - Create free account
   - Get your instance URL
   - Generate API key
   ```

2. **Copy environment:**
   ```bash
   cp .env.2gb .env
   ```

3. **Edit .env with Meilisearch Cloud details:**
   ```bash
   nano .env
   # Uncomment Option A:
   MEILISEARCH_HOST=https://your-instance.meilisearch.com
   MEILISEARCH_API_KEY=your-api-key
   ```

4. **Deploy with regular docker-compose (NOT .2gb version):**
   ```bash
   docker-compose build && docker-compose up -d
   ```

5. **Result:**
   ```
   Local RAM used: ~1.1GB (SAFE!)
   Search: Cloud (fast, scalable)
   Cost: FREE
   ```

---

### OPTION B: Disable Meilisearch (QUICK ⚡)

**Best:** Quick fix, frees 700MB RAM immediately  
**Cost:** FREE  
**Trade-off:** Basic search only (PostgreSQL full-text)

#### Steps:

1. **Edit BE_PMTL/package.json:**
   ```bash
   # Remove this line:
   "strapi-plugin-meilisearch": "^0.15.0"
   ```

2. **Copy environment:**
   ```bash
   cp .env.2gb .env
   ```

3. **Update .env:**
   ```bash
   # Use any docker-compose.yml (no Meilisearch settings needed)
   ```

4. **Deploy:**
   ```bash
   docker-compose build && docker-compose up -d
   ```

5. **Result:**
   ```
   Local RAM used: ~1.1GB (SAFE!)
   Search: PostgreSQL full-text
   Cost: FREE (no external service)
   ```

---

### OPTION C: Keep Meilisearch + Optimize (COMPLEX 🔧)

**Best:** Keep full Meilisearch features locally  
**Risk:** Tight memory, need swap, monitoring required  
**Setup Time:** 30 minutes

#### Prerequisites:

You need **2GB+ swap** on VPS:

```bash
# Check current swap
free -h

# If swap < 2GB, create it:
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make persistent (add to /etc/fstab):
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

#### Steps:

1. **Use optimized docker-compose:**
   ```bash
   cp .env.2gb .env
   # Edit .env with your secrets
   ```

2. **Deploy with 2GB version:**
   ```bash
   # Use docker-compose.prod.2gb.yml instead of regular one
   docker-compose -f docker-compose.prod.2gb.yml build
   docker-compose -f docker-compose.prod.2gb.yml up -d
   ```

3. **Memory Limits Applied:**
   - Postgres: 256MB (from 512MB+)
   - Backend: 384MB (from unlimited)
   - Frontend: 256MB (from unlimited)
   - Nginx: 64MB (from unlimited)
   - Meilisearch: ~700MB (in comments, uncomment if needed)

4. **Monitor constantly:**
   ```bash
   # Watch memory real-time
   watch -n 1 'free -h && echo && docker stats'
   
   # Check for OOM kills
   dmesg | grep -i killed | tail -5
   ```

5. **Result:**
   ```
   Local RAM used: 1.1-1.8GB (tight with swap)
   Search: Meilisearch (powerful but risky)
   Cost: FREE (local only)
   Risk: Slowness if swap is used
   ```

---

## 📋 Quick Decision Matrix

| Need | Option | Cost | Setup | RAM | Risk |
|------|--------|------|-------|-----|------|
| **Best Performance** | Cloud | FREE | 10min | 1.1GB | None |
| **Simple & Quick** | Disable | FREE | 5min | 1.1GB | None |
| **Keep Everything** | Optimize | FREE | 30min | 1.8GB | High |
| **Have spare $$ & time** | Upgrade VPS | +$$ | 10min | 4GB+ | None |

**Recommendation for YOU:** 
→ Use **Option A (Meilisearch Cloud)** - Best balance! 🌟

---

## 🚀 Recommended Path: Option A (Cloud)

### Step 1: Setup Meilisearch Cloud

```bash
# Go to https://cloud.meilisearch.com
# 1. Sign up (Google/GitHub works)
# 2. Create free account tier
# 3. Create new index
# 4. Copy these values:
#    - Meilisearch URL: https://xxx.meilisearch.com
#    - API Key: your-secret-key
```

### Step 2: Install & Deploy

```bash
# 1. On your VPS
ssh root@your-vps-ip
cd /apps/pmtl-vn

# 2. Copy environment
cp .env.2gb .env

# 3. Edit with Cloud details
nano .env

# Find and uncomment:
# MEILISEARCH_HOST=https://xxx.meilisearch.com
# MEILISEARCH_API_KEY=your-secret-key

# 4. Deploy normally
docker-compose build
docker-compose up -d
```

### Step 3: Verify

```bash
# Check all running
docker-compose ps

# Check search works
curl http://localhost/api/search/?query=test

# Monitor RAM
watch -n 1 free -h
# Should stay under 1.2GB
```

---

## 🔍 Monitoring Memory on 2GB VPS

### Check Current Usage

```bash
# See breakdown
free -h

# Example output:
# total    used  free
# 2.0G     1.3G  700M  ✅ Good
# 2.0G     1.9G  100M  ⚠️  Warning
# 2.0G     2.1G  -100M ❌ OOM killed!
```

### Setup Ongoing Monitoring

```bash
# Real-time dashboard (press Ctrl+C to exit)
watch -n 2 'echo "=== Memory ===" && free -h && echo && echo "=== Containers ===" && docker stats --no-stream'

# Or check every 5 min and log
while true; do
  {
    echo "$(date): $(free -h | grep Mem)"
    docker stats --no-stream
  } >> /var/log/pmtl-memory.log
  sleep 300
done &
```

### Troubleshoot if High Memory

```bash
# 1. Check which container uses most
docker stats --no-stream

# 2. Check if using swap (BAD)
grep SwapCached /proc/meminfo

# 3. If Meilisearch is problem:
#    - Switch to Cloud (Option A)
#    - Or disable it (Option B)

# 4. If Strapi/Next.js too high:
#    - Reduce their memory limits in docker-compose.yml
#    - Check for memory leaks
```

---

## 📝 Strapi Plugins Status

### What You Have:

```bash
✅ @_sh/strapi-plugin-ckeditor (7.0.0)
   - Rich editor for content
   - RAM: ~20MB
   - Keep it

✅ @strapi/plugin-users-permissions (5.38.0)
   - User auth & roles
   - RAM: ~30MB
   - Keep it

✅ @strapi/plugin-documentation (5.38.0)
   - Auto API docs (Swagger)
   - RAM: ~5MB
   - Keep it (useful for frontend devs)

✅ @strapi/plugin-cloud (5.38.0)
   - Deploy to Strapi Cloud
   - RAM: ~5MB
   - Keep or disable if not using

🔴 strapi-plugin-meilisearch (0.15.0)
   - Advanced search
   - RAM: 700MB-1GB ⚠️
   - FIX: Use Cloud version instead
```

### For 2GB VPS, Keep:
- ✅ CKEditor (necessary)
- ✅ Users-Permissions (auth)
- ✅ Documentation (helpful)
- ⚠️ Cloud Plugin (optional, light)
- 🔄 Meilisearch → **MOVE TO CLOUD**

---

## 🛠️ Deployment Commands for 2GB

### Option A: Cloud Meilisearch (Recommended)

```bash
# Regular docker-compose works fine
docker-compose build
docker-compose up -d
docker-compose logs -f
```

### Option B: Disable Meilisearch

```bash
# After removing from package.json:
docker-compose build
docker-compose up -d
docker-compose logs -f
```

### Option C: Local Meilisearch (Risky)

```bash
# Use optimized version
docker-compose -f docker-compose.prod.2gb.yml build
docker-compose -f docker-compose.prod.2gb.yml up -d

# Monitor constantly
watch -n 1 'free -h && docker stats'
```

---

## 📊 Performance Comparison

| Aspect | Drive | Cloud | Disabled |
|--------|-------|-------|----------|
| **Search Speed** | Instant | Instant | Slower |
| **RAM Local** | 1.8GB | 1.1GB | 1.1GB |
| **Maintenance** | Monitor swap | Hands-off | Manual + DB search |
| **Cost** | FREE | FREE-$15 | FREE |
| **Complexity** | High | Low | Low |
| **Reliability** | Risky | Safe | Safe |
| **Scalability** | Limited | Unlimited | Limited |

**Winner: Cloud** ⭐

---

## 🔄 Migration Path Later

If you outgrow 2GB:

```
2GB (Meilisearch Cloud) ──→ 4GB (Local Meilisearch)
    └─ Perfect for Medium traffic
```

Just upgrade VPS and:
```bash
# Switch environment
cp .env.production .env
docker-compose down
docker-compose up -d --build
```

---

## ✅ Final Setup Checklist

- [ ] Choose option (A, B, or C)
- [ ] Generate strong passwords
- [ ] Copy appropriate `.env` file
- [ ] Fill in your secrets
- [ ] Deploy with right docker-compose
- [ ] Check `docker-compose ps` - all running?
- [ ] Run `./health-check.sh` - all green?
- [ ] Monitor `free -h` - under 1.5GB?
- [ ] Test in browser - working?

**If all ✅:** You're good to go! 🚀

---

## 📞 Troubleshooting

### "Out of Memory" error?
→ Switch to **Option A (Cloud)** immediately

### "Meilisearch keeps crashing"?
→ It needs swap. Enable 2GB swap first, or switch to Cloud

### "High CPU usage"?
→ Might be indexing. Check Meilisearch dashboard

### "Slow response times"?
→ Probably swap being used. Switch to Cloud for speed

### "Container restart loop"?
→ Memory limit too low. Increase or switch option

---

## 🎓 Learning Resources

- [Meilisearch Cloud Docs](https://www.meilisearch.com/docs)
- [Docker Memory Constraints](https://docs.docker.com/config/containers/resource_constraints/)
- [Node.js Memory Management](https://nodejs.org/en/docs/guides/simple-profiling/)
- [Linux Swap Setup](https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-20-04/)

---

**v1.0** | Created: 2024 | Updated: March 2026
