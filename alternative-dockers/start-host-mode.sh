#!/bin/bash

# Make the host-diagnostic.sh script executable
chmod +x host-diagnostic.sh

# Copy the guacamole-host.properties to the main properties file
cp config/guacamole-host.properties config/guacamole.properties

# Stop any running containers
docker-compose down

# Start the containers with the fixed host network configuration
docker-compose -f docker-compose-host-fixed.yaml up -d

# Wait for services to initialize
echo "Waiting for services to initialize (60 seconds)..."
sleep 60

# Run diagnostics
./host-diagnostic.sh

echo ""
echo "Guacamole should now be accessible at: http://localhost:5000/"
echo "Username: guacadmin"
echo "Password: guacadmin"
echo ""
echo "If you still experience issues, check the logs with:"
echo "docker logs guacamole-daemon"
echo "docker logs guacamole-web"
echo "docker logs chrome"
