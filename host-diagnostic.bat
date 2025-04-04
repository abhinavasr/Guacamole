@echo off
REM Windows batch script for diagnosing Guacamole setup

echo === Guacamole Diagnostic Tool ===
echo Running diagnostics on host network configuration...
echo.

REM Check if Docker is running
echo 1. Checking Docker status:
docker info > nul 2>&1
if %ERRORLEVEL% == 0 (
  echo    √ Docker is running
) else (
  echo    × Docker is not running
  echo    Please start Docker and try again
  exit /b 1
)
echo.

REM Check container status
echo 2. Checking container status:
for %%c in (guacamole-postgres guacamole-daemon chrome guacamole-web) do (
  docker ps -q -f name=%%c > nul 2>&1
  if %ERRORLEVEL% == 0 (
    echo    √ %%c is running
  ) else (
    echo    × %%c is not running
  )
)
echo.

REM Check port availability
echo 3. Checking port availability:
for %%p in (5432 4822 5901 6901 5000) do (
  netstat -an | findstr ":%p " > nul 2>&1
  if %ERRORLEVEL% == 0 (
    echo    √ Port %%p is in use (expected)
  ) else (
    echo    × Port %%p is not in use (unexpected)
  )
)
echo.

REM Check network connectivity between services
echo 4. Testing network connectivity:
echo    Testing PostgreSQL connection:
docker exec guacamole-postgres pg_isready -h localhost -U guacamole_user -d guacamole_db > nul 2>&1
if %ERRORLEVEL% == 0 (
  echo    √ PostgreSQL connection successful
) else (
  echo    × PostgreSQL connection failed
)

echo    Testing guacd connection:
docker exec guacamole-daemon nc -z localhost 4822 > nul 2>&1
if %ERRORLEVEL% == 0 (
  echo    √ guacd connection successful
) else (
  echo    × guacd connection failed
)

echo    Testing VNC connection:
REM Using PowerShell to test TCP connection since Windows doesn't have nc by default
powershell -command "Test-NetConnection -ComputerName localhost -Port 5901 -InformationLevel Quiet" > nul 2>&1
if %ERRORLEVEL% == 0 (
  echo    √ VNC connection successful
) else (
  echo    × VNC connection failed
)
echo.

REM Check logs for errors
echo 5. Checking for errors in logs:
echo    guacd logs:
docker logs --tail 10 guacamole-daemon | findstr /i "error unable"
echo.
echo    guacamole-web logs:
docker logs --tail 10 guacamole-web | findstr /i "error unable"
echo.

echo === Diagnostic Complete ===
echo For detailed logs, run: docker logs ^<container-name^>

pause
