@echo off
REM Guacamole Admin Permissions Fix Setup Script
REM This script sets up Guacamole with fixed admin permissions

echo === Guacamole Admin Permissions Fix Setup ===

REM Stop any running containers
echo Stopping any running Guacamole containers...
docker-compose down -v

REM Start the containers with the admin fix configuration
echo Starting Guacamole with admin permissions fix...
docker-compose -f docker-compose-admin-fix.yaml up -d

REM Wait for services to initialize
echo Waiting for services to initialize (60 seconds)...
timeout /t 60 /nobreak

REM Run diagnostics
echo Running diagnostics...
powershell -Command "& {$ErrorActionPreference='SilentlyContinue'; $response = Invoke-WebRequest -Uri 'http://localhost:5000/' -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host 'Guacamole web interface is accessible' } else { Write-Host 'Guacamole web interface is not accessible' }}"

echo.
echo === Setup Complete ===
echo.
echo Access Guacamole at: http://localhost:5000/
echo Username: guacadmin
echo Password: guacadmin
echo.
echo The Chrome Browser connection should now be available in your connections list.
echo If you encounter any issues, please run the diagnostic script.
