#!/usr/bin/env bash

set -Eeuo pipefail

APP_DIR="${APP_DIR:-/root/pmtl-vn}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
ROOT_BRANCH="${ROOT_BRANCH:-main}"
FE_BRANCH="${FE_BRANCH:-main}"
BE_BRANCH="${BE_BRANCH:-main}"
NO_CACHE="${NO_CACHE:-0}"
SKIP_PULL="${SKIP_PULL:-0}"
SYNC_ROOT="${SYNC_ROOT:-0}"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }
log() { printf "[%s] %s\n" "$(timestamp)" "$*"; }
err() { printf "[%s] ERROR: %s\n" "$(timestamp)" "$*" >&2; }

usage() {
  cat <<'EOF'
Usage:
  ./scripts/prod-deploy.sh [options]

Options:
  --no-cache      Build images with --no-cache
  --skip-pull     Skip git pull step
  --sync-root     Also pull root repo (default: off)
  --root-branch   Root repo branch (default: main)
  --fe-branch     Frontend repo branch (default: main)
  --be-branch     Backend repo branch (default: main)
  --help          Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-cache)
      NO_CACHE=1
      shift
      ;;
    --skip-pull)
      SKIP_PULL=1
      shift
      ;;
    --sync-root)
      SYNC_ROOT=1
      shift
      ;;
    --root-branch)
      ROOT_BRANCH="${2:-}"
      shift 2
      ;;
    --fe-branch)
      FE_BRANCH="${2:-}"
      shift 2
      ;;
    --be-branch)
      BE_BRANCH="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Missing command: $1"
    exit 1
  fi
}

acquire_lock() {
  exec 9>/tmp/pmtl-prod-deploy.lock
  if ! flock -w 900 9; then
    err "Cannot acquire deploy lock (/tmp/pmtl-prod-deploy.lock). Another deploy may be running."
    exit 1
  fi
}

stash_if_dirty() {
  local repo="$1"
  pushd "$repo" >/dev/null
  if [[ -n "$(git status --porcelain)" ]]; then
    local name
    name="pre-deploy-$(basename "$repo")-$(date +%Y%m%d-%H%M%S)"
    log "Dirty repo detected in $(basename "$repo"), stashing as $name"
    git stash push -u -m "$name" >/dev/null
  fi
  popd >/dev/null
}

sync_repo() {
  local repo="$1"
  local branch="$2"
  pushd "$repo" >/dev/null
  stash_if_dirty "$repo"
  log "Sync $(basename "$repo") -> origin/$branch"
  git fetch origin "$branch" --prune
  git checkout "$branch" >/dev/null 2>&1 || true
  git pull --ff-only origin "$branch"
  popd >/dev/null
}

wait_health() {
  local container="$1"
  local timeout="${2:-240}"
  local elapsed=0
  local interval=5

  log "Waiting for health: $container"
  while (( elapsed < timeout )); do
    local status
    status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container" 2>/dev/null || echo "missing")"
    if [[ "$status" == "healthy" || "$status" == "running" ]]; then
      log "$container is $status"
      return 0
    fi
    if [[ "$status" == "unhealthy" || "$status" == "exited" || "$status" == "dead" || "$status" == "missing" ]]; then
      err "$container is $status"
      docker logs --tail 120 "$container" || true
      return 1
    fi
    sleep "$interval"
    elapsed=$((elapsed + interval))
  done

  err "Timeout waiting for $container health"
  docker logs --tail 120 "$container" || true
  return 1
}

main() {
  require_cmd git
  require_cmd docker
  require_cmd curl
  require_cmd flock
  acquire_lock

  if [[ ! -d "$APP_DIR" ]]; then
    err "APP_DIR not found: $APP_DIR"
    exit 1
  fi

  cd "$APP_DIR"

  if [[ ! -f "$COMPOSE_FILE" ]]; then
    err "Compose file not found: $APP_DIR/$COMPOSE_FILE"
    exit 1
  fi

  log "Deploy start in $APP_DIR"

  if [[ "$SKIP_PULL" != "1" ]]; then
    if [[ "$SYNC_ROOT" == "1" ]]; then
      sync_repo "$APP_DIR" "$ROOT_BRANCH"
    else
      log "Skip root repo sync (use --sync-root to enable)"
    fi
    sync_repo "$APP_DIR/BE_PMTL" "$BE_BRANCH"
    sync_repo "$APP_DIR/fe-pmtl" "$FE_BRANCH"
  else
    log "Skip git pull as requested"
  fi

  local build_flags=()
  if [[ "$NO_CACHE" == "1" ]]; then
    build_flags+=(--no-cache)
  fi

  log "Build backend/frontend"
  docker compose -f "$COMPOSE_FILE" build "${build_flags[@]}" backend frontend

  log "Start backend/frontend/nginx"
  docker compose -f "$COMPOSE_FILE" up -d --force-recreate backend frontend nginx

  wait_health pmtl-backend 300
  wait_health pmtl-frontend 300

  log "HTTP checks"
  curl -fsSI https://phapmontamlinh-quantheambotat.vn/ | sed -n '1p'
  # Some environments still have mismatched TLS cert on Strapi subdomain.
  if ! curl -fsSI https://strapi.phapmontamlinh-quantheambotat.vn/admin >/dev/null 2>&1; then
    log "Strapi TLS check failed, retrying with --insecure"
    curl -ksSI https://strapi.phapmontamlinh-quantheambotat.vn/admin | sed -n '1p' || true
  else
    curl -sSI https://strapi.phapmontamlinh-quantheambotat.vn/admin | sed -n '1p'
  fi

  log "Deploy completed"
  docker ps --format 'table {{.Names}}\t{{.Status}}'
}

main "$@"
