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
