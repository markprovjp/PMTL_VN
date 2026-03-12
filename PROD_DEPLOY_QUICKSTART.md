# Production Deploy Quickstart

## One-command deploy on VPS

Run:

```bash
ssh pmtl-vps "cd /root/pmtl-vn && bash scripts/prod-deploy.sh"
```

This command will:

1. Pull latest code for root repo, `BE_PMTL`, and `fe-pmtl`
2. Auto-stash dirty local changes on VPS (safe)
3. Build backend + frontend Docker images
4. Recreate backend/frontend/nginx containers
5. Wait for container health
6. Run endpoint checks:
   - `https://phapmontamlinh-quantheambotat.vn/`
   - `https://strapi.phapmontamlinh-quantheambotat.vn/admin`

## Fast status check

```bash
ssh pmtl-vps "cd /root/pmtl-vn && bash scripts/prod-status.sh"
```

## Useful options

```bash
# Rebuild without Docker cache
ssh pmtl-vps "cd /root/pmtl-vn && bash scripts/prod-deploy.sh --no-cache"

# Deploy without pulling (only rebuild/restart current VPS code)
ssh pmtl-vps "cd /root/pmtl-vn && bash scripts/prod-deploy.sh --skip-pull"
```

## Recommended daily flow

1. Code on dev machine
2. Commit + push FE/BE
3. Run one deploy command above
4. Verify website quickly with `prod-status.sh`
