$cmd = "cd /root/pmtl-vn && bash scripts/prod-status.sh"
Write-Host "Running remote status check..." -ForegroundColor Cyan
ssh pmtl-vps $cmd
