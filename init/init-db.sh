#!/bin/bash
set -e
# Wait for PostgreSQL to be ready
until PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -c '\q'; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done
>&2 echo "PostgreSQL is up - executing schema scripts"
# Execute schema scripts
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/01-schema.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/02-create-admin-user.sql
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/03-user-attribute.sql
>&2 echo "Schema initialization completed successfully"
