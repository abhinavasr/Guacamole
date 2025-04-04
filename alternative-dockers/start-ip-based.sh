#!/bin/bash

# Make the diagnostic script executable
chmod +x host-diagnostic.sh

# Stop any running containers
echo "Stopping any running Guacamole containers..."
docker-compose down

# Start the containers with the IP-based solution configuration
echo "Starting Guacamole with IP-based solution configuration..."
docker-compose -f docker-compose-ip-based.yaml up -d

# Wait for services to initialize
echo "Waiting for services to initialize (90 seconds)..."
echo "This longer wait ensures the Chrome VNC server is fully started and IP address is properly resolved..."
sleep 90

# Run diagnostics
echo "Running diagnostics..."
./host-diagnostic.sh

echo ""
echo "Guacamole should now be accessible at: http://localhost:5000/"
echo "Username: guacadmin"
echo "Password: guacadmin"
echo ""
echo "This configuration uses direct IP addressing between containers for reliable connectivity."
echo "The necessary ports (4822, 5901, 6901) are exposed for proper connectivity and debugging."
echo ""
echo "For direct VNC access (for testing purposes):"
echo "- VNC client: localhost:5901 (password: passwd)"
echo "- noVNC browser client: http://localhost:6901 (password: passwd)"
echo ""
echo "If you still experience issues, check the logs with:"
echo "docker logs guacamole-daemon"
echo "docker logs guacamole-web"
echo "docker logs chrome"
echo "docker logs guacamole-init-db"
