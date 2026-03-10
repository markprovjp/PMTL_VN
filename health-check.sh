#!/bin/bash

# Health Check Script for PMTL_VN
# Monitor services and alert if issues detected

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Log file
LOG_FILE="health-check.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check container status
check_containers() {
    log "Checking container status..."
    
    RUNNING=$(docker-compose ps --services --filter "status=running" | wc -l)
    TOTAL=$(docker-compose config --services | wc -l)
    
    if [ "$RUNNING" -ne "$TOTAL" ]; then
        log "${RED}ERROR: Not all containers running ($RUNNING/$TOTAL)${NC}"
        docker-compose ps
        return 1
    fi
    
    log "${GREEN}OK: All containers running ($RUNNING/$TOTAL)${NC}"
    return 0
}

# Check database
check_database() {
    log "Checking database..."
    
    if docker-compose exec -T postgres pg_isready -U strapi_user &>/dev/null; then
        log "${GREEN}OK: Database is ready${NC}"
        
        # Check connection to strapi_db
        if docker-compose exec -T postgres psql -U strapi_user -d strapi_db -c "SELECT 1" &>/dev/null; then
            log "${GREEN}OK: Can connect to strapi_db${NC}"
            return 0
        else
            log "${RED}ERROR: Cannot connect to strapi_db${NC}"
            return 1
        fi
    else
        log "${RED}ERROR: Database is not ready${NC}"
        return 1
    fi
}

# Check backend API
check_backend() {
    log "Checking backend API..."
    
    STATUS=$(docker-compose exec -T backend curl -s -o /dev/null -w "%{http_code}" http://localhost:1337/admin 2>/dev/null || echo "000")
    
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
        log "${GREEN}OK: Backend API responding (HTTP $STATUS)${NC}"
        return 0
    else
        log "${RED}ERROR: Backend API not responding (HTTP $STATUS)${NC}"
        return 1
    fi
}

# Check frontend
check_frontend() {
    log "Checking frontend..."
    
    STATUS=$(docker-compose exec -T frontend curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
    
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
        log "${GREEN}OK: Frontend responding (HTTP $STATUS)${NC}"
        return 0
    else
        log "${RED}ERROR: Frontend not responding (HTTP $STATUS)${NC}"
        return 1
    fi
}

# Check nginx
check_nginx() {
    log "Checking Nginx..."
    
    if docker-compose exec nginx nginx -t 2>&1 | grep -q "successful"; then
        log "${GREEN}OK: Nginx config is valid${NC}"
        
        STATUS=$(docker-compose exec -T nginx curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
        if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
            log "${GREEN}OK: Nginx responding (HTTP $STATUS)${NC}"
            return 0
        else
            log "${RED}ERROR: Nginx not responding (HTTP $STATUS)${NC}"
            return 1
        fi
    else
        log "${RED}ERROR: Nginx config is invalid${NC}"
        return 1
    fi
}

# Check disk space
check_disk() {
    log "Checking disk space..."
    
    USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$USAGE" -gt 90 ]; then
        log "${RED}WARNING: Disk usage high (${USAGE}%)${NC}"
        return 1
    elif [ "$USAGE" -gt 80 ]; then
        log "${YELLOW}WARNING: Disk usage moderate (${USAGE}%)${NC}"
        return 0
    else
        log "${GREEN}OK: Disk usage normal (${USAGE}%)${NC}"
        return 0
    fi
}

# Check docker volumes
check_volumes() {
    log "Checking volumes..."
    
    if docker volume ls | grep -q "pmtl"; then
        log "${GREEN}OK: Required volumes exist${NC}"
        return 0
    else
        log "${RED}ERROR: Missing volumes${NC}"
        return 1
    fi
}

# Restart unhealthy containers
restart_unhealthy() {
    log "Checking for unhealthy containers..."
    
    UNHEALTHY=$(docker-compose ps | grep unhealthy | awk '{print $1}' || true)
    
    if [ -n "$UNHEALTHY" ]; then
        log "${YELLOW}WARNING: Found unhealthy containers: $UNHEALTHY${NC}"
        for container in $UNHEALTHY; do
            log "Restarting $container..."
            docker-compose restart "$container"
        done
    else
        log "${GREEN}OK: No unhealthy containers${NC}"
    fi
}

# Generate report
generate_report() {
    log "\n======================================="
    log "Health Check Report"
    log "======================================="
    
    ERRORS=0
    WARNINGS=0
    
    if ! check_containers; then ((ERRORS++)); fi
    if ! check_database; then ((ERRORS++)); fi
    if ! check_backend; then ((ERRORS++)); fi
    if ! check_frontend; then ((ERRORS++)); fi
    if ! check_nginx; then ((ERRORS++)); fi
    if ! check_disk; then ((WARNINGS++)); fi
    if ! check_volumes; then ((ERRORS++)); fi
    
    restart_unhealthy
    
    log "\n======================================="
    log "Summary: Errors=$ERRORS, Warnings=$WARNINGS"
    log "======================================="
    
    if [ $ERRORS -gt 0 ]; then
        log "${RED}⚠️  Health check FAILED${NC}"
        return 1
    else
        log "${GREEN}✓ Health check PASSED${NC}"
        return 0
    fi
}

# Main
main() {
    cd "$SCRIPT_DIR"
    
    log "Starting health check..."
    log "Environment: $(grep NODE_ENV .env | cut -d= -f2)"
    
    generate_report
    EXIT_CODE=$?
    
    log "Health check completed at $(date)"
    
    exit $EXIT_CODE
}

main
