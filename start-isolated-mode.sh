#!/bin/bash

# Make the diagnostic script executable
chmod +x host-diagnostic.sh

# Stop any running containers
echo "Stopping any running Guacamole containers..."
docker-compose down

# Start the containers with the isolated network configuration
echo "Starting Guacamole with isolated network configuration..."
docker-compose -f docker-compose-isolated.yaml up -d

# Wait for services to initialize
echo "Waiting for services to initialize (60 seconds)..."
sleep 60

# Run diagnostics
echo "Running diagnostics..."
./host-diagnostic.sh

echo ""
echo "Guacamole should now be accessible at: http://localhost:5000/"
echo "Username: guacadmin"
echo "Password: guacadmin"
echo ""
echo "This configuration uses an isolated network (172.28.0.0/16) that won't interfere with other Docker applications."
echo ""
echo "If you still experience issues, check the logs with:"
echo "docker logs guacamole-daemon"
echo "docker logs guacamole-web"
echo "docker logs chrome"
