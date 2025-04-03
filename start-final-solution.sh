#!/bin/bash

# Make the diagnostic script executable
chmod +x host-diagnostic.sh

# Stop any running containers
echo "Stopping any running Guacamole containers..."
docker-compose down

# Start the containers with the final solution configuration
echo "Starting Guacamole with final solution configuration..."
docker-compose -f docker-compose-final-solution.yaml up -d

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
echo "The necessary ports (4822, 5901, 6901) are now exposed for proper connectivity."
echo ""
echo "For direct VNC access (for testing purposes):"
echo "- VNC client: localhost:5901 (password: passwd)"
echo "- noVNC browser client: http://localhost:6901 (password: passwd)"
echo ""
echo "If you still experience issues, check the logs with:"
echo "docker logs guacamole-daemon"
echo "docker logs guacamole-web"
echo "docker logs chrome"
