#!/bin/bash
set -e

# This script is the main entry point for PostgreSQL initialization
# It will be executed by PostgreSQL container during first startup

# Wait for Chrome container to be available
echo "Waiting for Chrome container to be available..."
until ping -c 1 chrome > /dev/null 2>&1; do
  echo "Chrome container not yet available - waiting..."
  sleep 5
done

# Get Chrome container IP address
CHROME_IP=$(getent hosts chrome | awk '{ print $1 }')
echo "Chrome container IP: $CHROME_IP"

# Create Chrome connection SQL with proper IP address
sed "s/CHROME_IP_ADDRESS/$CHROME_IP/g" /docker-entrypoint-initdb.d/04-create-chrome-connection-ip.sql > /docker-entrypoint-initdb.d/04-chrome-connection-final.sql

echo "Database initialization files prepared successfully"
