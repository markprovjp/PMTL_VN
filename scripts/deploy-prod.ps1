param(
  [switch]$NoCache,
  [switch]$SkipPull
)

$remoteFlags = @()
if ($NoCache) { $remoteFlags += "--no-cache" }
if ($SkipPull) { $remoteFlags += "--skip-pull" }

$flagText = if ($remoteFlags.Count -gt 0) { " " + ($remoteFlags -join " ") } else { "" }
$cmd = "cd /root/pmtl-vn && bash scripts/prod-deploy.sh$flagText"

Write-Host "Running remote deploy: $cmd" -ForegroundColor Cyan
ssh pmtl-vps $cmd
