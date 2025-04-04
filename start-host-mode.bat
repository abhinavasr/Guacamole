@echo off
REM Windows batch script for starting Guacamole with host network mode

echo Making the host-diagnostic script executable...
REM No need for chmod in Windows

REM Copy the guacamole-host.properties to the main properties file
copy config\guacamole-host.properties config\guacamole.properties

REM Stop any running containers
echo Stopping any running Guacamole containers...
docker-compose down

REM Start the containers with the fixed host network configuration
echo Starting the containers with the fixed host network configuration...
docker-compose -f docker-compose-host-fixed.yaml up -d

REM Wait for services to initialize
echo Waiting for services to initialize (60 seconds)...
timeout /t 60 /nobreak

REM Run diagnostics
echo Running diagnostics...
call host-diagnostic.bat

echo.
echo Guacamole should now be accessible at: http://localhost:5000/
echo Username: guacadmin
echo Password: guacadmin
echo.
echo If you still experience issues, check the logs with:
echo docker logs guacamole-daemon
echo docker logs guacamole-web
echo docker logs chrome

pause
