#!/bin/bash

# This script prepares the initialization SQL files for PostgreSQL
# It creates a single combined SQL file with Chrome connection configuration

# Get Chrome container IP address
CHROME_IP=$(getent hosts chrome | awk '{ print $1 }')
echo "Chrome container IP: $CHROME_IP"

# Create combined SQL file
cat /init/01-schema.sql /init/02-create-admin-user.sql /init/03-user-attribute.sql /init/05-connection-attribute.sql /init/06-cleanup-duplicate-connections.sql > /init/00-combined.sql

# Create Chrome connection SQL with proper IP address
sed "s/CHROME_IP_ADDRESS/$CHROME_IP/g" /init/04-create-chrome-connection-ip.sql > /init/07-chrome-connection.sql

echo "Database initialization files prepared successfully"
