#!/bin/bash

# Diagnostic script for Guacamole host network configuration

echo "=== Guacamole Diagnostic Tool ==="
echo "Running diagnostics on host network configuration..."
echo

# Check if Docker is running
echo "1. Checking Docker status:"
if docker info >/dev/null 2>&1; then
  echo "   ✓ Docker is running"
else
  echo "   ✗ Docker is not running"
  echo "   Please start Docker and try again"
  exit 1
fi
echo

# Check container status
echo "2. Checking container status:"
for container in guacamole-postgres guacamole-daemon chrome guacamole-web; do
  if docker ps -q -f name=$container | grep -q .; then
    echo "   ✓ $container is running"
  else
    echo "   ✗ $container is not running"
  fi
done
echo

# Check port availability
echo "3. Checking port availability:"
for port in 5432 4822 5901 6901 5000; do
  if netstat -tuln | grep -q ":$port "; then
    echo "   ✓ Port $port is in use (expected)"
  else
    echo "   ✗ Port $port is not in use (unexpected)"
  fi
done
echo

# Check network connectivity between services
echo "4. Testing network connectivity:"
echo "   Testing PostgreSQL connection:"
if docker exec guacamole-postgres pg_isready -h localhost -U guacamole_user -d guacamole_db >/dev/null 2>&1; then
  echo "   ✓ PostgreSQL connection successful"
else
  echo "   ✗ PostgreSQL connection failed"
fi

echo "   Testing guacd connection:"
if docker exec guacamole-daemon nc -z localhost 4822 >/dev/null 2>&1; then
  echo "   ✓ guacd connection successful"
else
  echo "   ✗ guacd connection failed"
fi

echo "   Testing VNC connection:"
if nc -z localhost 5901 >/dev/null 2>&1; then
  echo "   ✓ VNC connection successful"
else
  echo "   ✗ VNC connection failed"
fi
echo

# Check logs for errors
echo "5. Checking for errors in logs:"
echo "   guacd logs:"
docker logs --tail 10 guacamole-daemon | grep -i "error\|unable"
echo
echo "   guacamole-web logs:"
docker logs --tail 10 guacamole-web | grep -i "error\|unable"
echo

echo "=== Diagnostic Complete ==="
echo "For detailed logs, run: docker logs <container-name>"
