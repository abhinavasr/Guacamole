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
for SCRIPT in /schema/01-schema.sql /schema/02-create-admin-user.sql /schema/03-user-attribute.sql; do
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

# Directly apply admin permissions without requiring a separate file
echo "Applying admin permissions directly..."
PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db << 'EOF'
-- Grant system permissions to guacadmin
INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission::guacamole_system_permission_type
FROM (
    SELECT entity_id, 'ADMINISTER' AS permission
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER'
) AS permissions
WHERE NOT EXISTS (
    SELECT 1 FROM guacamole_system_permission
    WHERE entity_id = permissions.entity_id
    AND permission = permissions.permission::guacamole_system_permission_type
);

-- Grant create connection permissions
INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission::guacamole_system_permission_type
FROM (
    SELECT entity_id, 'CREATE_CONNECTION' AS permission
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER'
) AS permissions
WHERE NOT EXISTS (
    SELECT 1 FROM guacamole_system_permission
    WHERE entity_id = permissions.entity_id
    AND permission = permissions.permission::guacamole_system_permission_type
);
EOF

echo "Admin permissions applied successfully"
echo "Schema initialization completed successfully"
echo "Guacamole database is now ready for use"
exit 0
