@echo off
setlocal enabledelayedexpansion

cls
echo.
echo ========================================
echo   PMTL - FE ^& BE Runner
echo ========================================
echo.
echo 1. Chay ca FE va BE
echo 2. Chay FE (fe-pmtl) - port 3000
echo 3. Chay BE (BE_PMTL) - port 1337
echo 4. Kill nhanh cac tien trinh dev
echo.
set /p choice="Chon lua chon (1/2/3/4): "

if "%choice%"=="1" (
    echo.
    echo [INFO] Khoi dong Redis, Meilisearch, FE va BE...
    docker container inspect pmtl-redis-dev >nul 2>&1
    if errorlevel 1 (
        start "PMTL-Redis" cmd /k "docker run --name pmtl-redis-dev -p 6379:6379 redis:7-alpine redis-server --appendonly yes"
    ) else (
        start "PMTL-Redis" cmd /k "docker start -ai pmtl-redis-dev"
    )
    ping 127.0.0.1 -n 3 > nul

    docker container inspect pmtl-meili-dev >nul 2>&1
    if errorlevel 1 (
        start "PMTL-Meili" cmd /k "docker run --name pmtl-meili-dev -p 7700:7700 getmeili/meilisearch:latest meilisearch --master-key=super-secret-key-12345"
    ) else (
        start "PMTL-Meili" cmd /k "docker start -ai pmtl-meili-dev"
    )
    ping 127.0.0.1 -n 3 > nul

    start "PMTL-FE" cmd /k "cd fe-pmtl && npm run dev"
    ping 127.0.0.1 -n 3 > nul
    start "PMTL-BE" cmd /k "cd BE_PMTL && npm run develop"
    echo [OK] Redis chay tai localhost:6379
    echo [OK] Meilisearch chay tai http://localhost:7700
    echo [OK] FE chay tai http://localhost:3000
    echo [OK] BE chay tai http://localhost:1337
    echo.
    echo Close windows nay de thoat
    pause
) else if "%choice%"=="2" (
    echo.
    echo [INFO] Khoi dong FE...
    cd fe-pmtl
    npm run dev
) else if "%choice%"=="3" (
    echo.
    echo [INFO] Khoi dong BE...
    cd BE_PMTL
    npm run develop
) else if "%choice%"=="4" (
    echo.
    echo [INFO] Kill cac tien trinh dev thong dung...
    call kill-dev.bat
    pause
) else (
    echo.
    echo [ERROR] Lua chon khong hop le!
    pause
    exit /b 1
)
