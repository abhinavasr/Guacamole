@echo off
echo Cleaning up any existing containers...
docker-compose down -v

echo Starting Guacamole services...
docker-compose up -d

echo Waiting for services to initialize (this may take a minute)...
timeout /t 60

echo Guacamole should now be accessible at: http://localhost:5000/
echo Username: guacadmin
echo Password: guacadmin
