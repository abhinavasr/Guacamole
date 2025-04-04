#!/bin/bash
set -e

# This script prepares the SQL initialization files for PostgreSQL
# It will be executed by the postgres container during initialization

# Create a combined SQL file with all schema and user creation
cat /docker-entrypoint-initdb.d/01-schema.sql > /docker-entrypoint-initdb.d/00-init-combined.sql
cat /docker-entrypoint-initdb.d/02-create-admin-user.sql >> /docker-entrypoint-initdb.d/00-init-combined.sql
cat /docker-entrypoint-initdb.d/03-user-attribute.sql >> /docker-entrypoint-initdb.d/00-init-combined.sql
cat /docker-entrypoint-initdb.d/05-connection-attribute.sql >> /docker-entrypoint-initdb.d/00-init-combined.sql
cat /docker-entrypoint-initdb.d/06-cleanup-duplicate-connections.sql >> /docker-entrypoint-initdb.d/00-init-combined.sql

# Create a placeholder for the Chrome connection that will be updated later
echo "-- Chrome connection will be added by a separate script" > /docker-entrypoint-initdb.d/99-placeholder.sql

echo "Database initialization files prepared successfully"
