@echo off
REM PMTL_VN - Quick Deployment Script (Windows)
REM Usage: deploy.bat [dev|prod]

setlocal enabledelayedexpansion

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

if "%ENVIRONMENT%"=="dev" (
    set ENV_FILE=.env.dev
) else if "%ENVIRONMENT%"=="prod" (
    set ENV_FILE=.env.production
) else (
    echo Invalid environment. Use 'dev' or 'prod'
    exit /b 1
)

cls
echo.
echo ======================================
echo PMTL_VN Deployment Script
echo Environment: %ENVIRONMENT%
echo ======================================
echo.

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not in PATH
    exit /b 1
)
echo [OK] Docker is installed

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed
    exit /b 1
)
echo [OK] Docker Compose is installed

REM Setup environment
echo.
echo Setting up %ENVIRONMENT% environment...

if not exist "%ENV_FILE%" (
    echo [ERROR] %ENV_FILE% not found
    exit /b 1
)

if exist ".env" (
    echo [WARNING] .env already exists, backing up to .env.backup
    copy .env .env.backup >nul
)

copy "%ENV_FILE%" .env >nul
echo [OK] Environment file configured

if "%ENVIRONMENT%"=="prod" (
    echo.
    echo [WARNING] PRODUCTION MODE
    echo Update these in .env:
    echo   - DATABASE_PASSWORD
    echo   - APP_KEYS, API_TOKEN_SALT, ADMIN_JWT_SECRET, etc.
    echo   - NEXT_PUBLIC_API_URL (set to your domain)
    echo.
    pause
)

REM Build and start
echo.
echo Building Docker images...
docker-compose build
if errorlevel 1 (
    echo [ERROR] Docker build failed
    exit /b 1
)
echo [OK] Docker images built

echo.
echo Starting services...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start services
    exit /b 1
)
echo [OK] Services started

echo.
echo Waiting for services to be healthy...
timeout /t 10 /nobreak

echo.
echo Service Status:
docker-compose ps

echo.
echo ======================================
if "%ENVIRONMENT%"=="dev" (
    echo DEPLOYMENT COMPLETE!
    echo.
    echo Frontend:  http://localhost
    echo API:       http://localhost/api
    echo Admin:     http://localhost/admin
    echo Database:  localhost:5432
) else (
    for /f "tokens=2 delims==" %%a in ('findstr NEXT_PUBLIC_SITE_URL .env') do set DOMAIN=%%a
    echo DEPLOYMENT COMPLETE!
    echo.
    echo Frontend:  !DOMAIN!
    echo API:       !DOMAIN!/api
    echo Admin:     !DOMAIN!/admin
)

echo.
echo Useful commands:
echo   View logs:       docker-compose logs -f
echo   Backend logs:    docker-compose logs -f backend
echo   Restart service: docker-compose restart [backend/frontend/nginx]
echo   Stop services:   docker-compose down
echo ======================================
echo.
pause
