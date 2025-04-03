#!/bin/bash

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -c '\q'; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL is up - executing schema scripts"

# Execute schema scripts
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/01-schema.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/02-create-admin-user.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/03-user-attribute.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/05-connection-attribute.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/06-cleanup-duplicate-connections.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/04-create-chrome-connection.sql

echo "Database initialization completed successfully"
