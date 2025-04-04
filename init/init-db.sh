#!/bin/bash

# This script creates a custom initialization script for PostgreSQL
# It will be executed when the PostgreSQL container starts

# Create a temporary directory for initialization files
mkdir -p /tmp/init

# Copy the schema and user creation SQL files
cp /docker-entrypoint-initdb.d/01-schema.sql /tmp/init/
cp /docker-entrypoint-initdb.d/02-create-admin-user.sql /tmp/init/
cp /docker-entrypoint-initdb.d/03-user-attribute.sql /tmp/init/
cp /docker-entrypoint-initdb.d/05-connection-attribute.sql /tmp/init/
cp /docker-entrypoint-initdb.d/06-cleanup-duplicate-connections.sql /tmp/init/

# Wait for Chrome container to be available
echo "Waiting for Chrome container to be available..."
until getent hosts chrome; do
  echo "Chrome container not yet available - waiting..."
  sleep 5
done

# Get Chrome container IP address
CHROME_IP=$(getent hosts chrome | awk '{ print $1 }')
echo "Chrome container IP: $CHROME_IP"

# Create Chrome connection SQL with proper IP address
sed "s/CHROME_IP_ADDRESS/$CHROME_IP/g" /docker-entrypoint-initdb.d/04-create-chrome-connection-ip.sql > /tmp/init/04-chrome-connection.sql

# Combine all SQL files into a single initialization file
cat /tmp/init/01-schema.sql \
    /tmp/init/02-create-admin-user.sql \
    /tmp/init/03-user-attribute.sql \
    /tmp/init/05-connection-attribute.sql \
    /tmp/init/06-cleanup-duplicate-connections.sql \
    /tmp/init/04-chrome-connection.sql > /docker-entrypoint-initdb.d/00-init.sql

echo "Database initialization files prepared successfully"

# Execute the SQL file (this will be done automatically by PostgreSQL)
