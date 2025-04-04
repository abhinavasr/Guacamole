@echo off
echo === Guacamole Simple Deployment Setup ===

REM Clean up any existing containers and volumes
echo Cleaning up any existing containers...
docker-compose down -v

REM Create initialization script if it doesn't exist
echo Creating initialization script...
if not exist "init\00-init-setup.sh" (
    echo #!/bin/bash > init\00-init-setup.sh
    echo echo "Initializing database..." >> init\00-init-setup.sh
)

REM Remove read-only attribute from scripts
echo Setting script permissions...
attrib -R .\init\*.sh

REM Start the containers with the simplified configuration
echo Starting Guacamole services...
docker-compose up -d

REM Wait for services to initialize
echo Waiting for services to initialize (this may take a minute)...
timeout /t 60

REM Run manual database initialization
echo Running database initialization...
docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\01-schema.sql
docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\02-create-admin-user.sql
docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\03-admin-permissions.sql
docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\03-user-attribute.sql
docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\05-connection-attribute.sql

REM Get Chrome container IP address
echo Getting Chrome container IP address...
FOR /F "tokens=*" %%i IN ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" chrome') DO SET CHROME_IP=%%i
echo Chrome IP: %CHROME_IP%

REM Create Chrome connection
echo Creating Chrome connection...
echo CREATE TEMP TABLE params (param_name text, param_value text); > init\temp-chrome.sql
echo INSERT INTO params VALUES ('hostname', '%CHROME_IP%'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('port', '5901'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('password', 'passwd'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('enable-audio', 'true'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('security', 'none'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('ignore-cert', 'true'); >> init\temp-chrome.sql
echo INSERT INTO params VALUES ('autoretry', '10'); >> init\temp-chrome.sql
echo INSERT INTO guacamole_connection (connection_name, protocol) VALUES ('Chrome Browser', 'vnc') RETURNING connection_id; >> init\temp-chrome.sql
echo INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) SELECT currval('guacamole_connection_connection_id_seq'), param_name, param_value FROM params; >> init\temp-chrome.sql
echo INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission) SELECT entity_id, currval('guacamole_connection_connection_id_seq'), permission FROM guacamole_entity, (VALUES ('READ'), ('UPDATE'), ('DELETE'), ('ADMINISTER')) permissions(permission) WHERE name = 'guacadmin'; >> init\temp-chrome.sql

docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db < init\temp-chrome.sql

echo.
echo === Setup Complete ===
echo.
echo Access Guacamole at: http://localhost:5000/
echo Username: guacadmin
echo Password: guacadmin
echo.
echo The Chrome Browser connection should now be available in your connections list.
