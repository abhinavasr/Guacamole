#!/bin/bash
set -e

echo "Starting Guacamole database initialization..."

# Wait for PostgreSQL to be ready with timeout
MAX_TRIES=30
COUNTER=0
echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -c '\q' 2>/dev/null; do
  COUNTER=$((COUNTER+1))
  if [ $COUNTER -ge $MAX_TRIES ]; then
    echo "ERROR: PostgreSQL connection timed out after $MAX_TRIES attempts. Exiting."
    exit 1
  fi
  echo "PostgreSQL is unavailable - sleeping (attempt $COUNTER/$MAX_TRIES)"
  sleep 2
done

echo "PostgreSQL is up and ready - executing schema scripts"

# Execute schema scripts with error handling
for SCRIPT in /schema/01-schema.sql /schema/02-create-admin-user.sql /schema/03-user-attribute.sql /schema/04-fix-permissions.sql; do
  if [ -f "$SCRIPT" ]; then
    echo "Executing $SCRIPT..."
    if PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f "$SCRIPT"; then
      echo "Successfully executed $SCRIPT"
    else
      echo "ERROR: Failed to execute $SCRIPT"
      exit 1
    fi
  else
    echo "WARNING: Script $SCRIPT not found"
    exit 1
  fi
done

echo "Schema initialization completed successfully"
echo "Guacamole database is now ready for use"
exit 0
