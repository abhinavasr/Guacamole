-- Enhanced Admin Permissions SQL Script
-- This script ensures the guacadmin user exists with proper permissions
-- and creates the Chrome VNC connection with correct parameters

-- First ensure the guacadmin user exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM guacamole_entity WHERE name = 'guacadmin' AND type = 'USER') THEN
        -- Create the guacadmin user entity
        INSERT INTO guacamole_entity (name, type) 
        VALUES ('guacadmin', 'USER');
        
        -- Create the guacadmin user with password "guacadmin"
        INSERT INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
        SELECT
            entity_id,
            decode('CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960', 'hex'),
            decode('FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264', 'hex'),
            CURRENT_TIMESTAMP
        FROM guacamole_entity WHERE name = 'guacadmin';
    END IF;
END $$;

-- Grant all system permissions to guacadmin
INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission::guacamole_system_permission_type
FROM guacamole_entity, (
    VALUES ('CREATE_CONNECTION'),
           ('CREATE_CONNECTION_GROUP'),
           ('CREATE_SHARING_PROFILE'),
           ('CREATE_USER'),
           ('CREATE_USER_GROUP'),
           ('ADMINISTER')
) permissions (permission)
WHERE guacamole_entity.name = 'guacadmin'
AND NOT EXISTS (
    SELECT 1 FROM guacamole_system_permission 
    WHERE entity_id = guacamole_entity.entity_id 
    AND permission = permissions.permission::guacamole_system_permission_type
);

-- Grant admin permission to read/update/administer self
INSERT INTO guacamole_user_permission (entity_id, affected_user_id, permission)
SELECT 
    guacamole_entity.entity_id, 
    guacamole_user.user_id, 
    permission::guacamole_object_permission_type
FROM (
    VALUES ('READ'),
           ('UPDATE'),
           ('ADMINISTER')
) permissions (permission)
CROSS JOIN guacamole_entity
CROSS JOIN guacamole_user
WHERE guacamole_entity.name = 'guacadmin' 
AND guacamole_entity.type = 'USER'
AND guacamole_user.entity_id = guacamole_entity.entity_id
AND NOT EXISTS (
    SELECT 1 FROM guacamole_user_permission
    WHERE entity_id = guacamole_entity.entity_id
    AND affected_user_id = guacamole_user.user_id
    AND permission = permissions.permission::guacamole_object_permission_type
);

-- Ensure Chrome VNC connection exists and admin has permissions to it
DO $$
DECLARE
    chrome_connection_id INT;
    admin_entity_id INT;
BEGIN
    -- Get admin entity ID
    SELECT entity_id INTO admin_entity_id
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';
    
    -- Check if Chrome connection exists, create if not
    IF NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name = 'Chrome Browser') THEN
        INSERT INTO guacamole_connection (connection_name, protocol)
        VALUES ('Chrome Browser', 'vnc');
    END IF;
    
    -- Get the connection_id for the Chrome connection
    SELECT connection_id INTO chrome_connection_id
    FROM guacamole_connection
    WHERE connection_name = 'Chrome Browser';
    
    -- Delete any existing parameters to avoid duplicates
    DELETE FROM guacamole_connection_parameter 
    WHERE connection_id = chrome_connection_id;
    
    -- Insert Chrome connection parameters
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
        (chrome_connection_id, 'hostname', 'chrome'),
        (chrome_connection_id, 'port', '5901'),
        (chrome_connection_id, 'password', 'passwd'),
        (chrome_connection_id, 'enable-audio', 'true'),
        (chrome_connection_id, 'color-depth', '24'),
        (chrome_connection_id, 'swap-red-blue', 'false'),
        (chrome_connection_id, 'cursor', 'local'),
        (chrome_connection_id, 'read-only', 'false'),
        (chrome_connection_id, 'security', 'none'),
        (chrome_connection_id, 'ignore-cert', 'true'),
        (chrome_connection_id, 'autoretry', '10'),
        (chrome_connection_id, 'enable-sftp', 'false'),
        (chrome_connection_id, 'create-recording-path', 'false'),
        (chrome_connection_id, 'recording-name', ''),
        (chrome_connection_id, 'recording-exclude-output', 'false'),
        (chrome_connection_id, 'recording-exclude-mouse', 'false'),
        (chrome_connection_id, 'recording-include-keys', 'false'),
        (chrome_connection_id, 'create-drive-path', 'false'),
        (chrome_connection_id, 'enable-audio-input', 'false'),
        (chrome_connection_id, 'enable-force-lossless', 'false'),
        (chrome_connection_id, 'resize-method', 'display-update'),
        (chrome_connection_id, 'clipboard-encoding', 'UTF-8'),
        (chrome_connection_id, 'dest-port', ''),
        (chrome_connection_id, 'recording-path', ''),
        (chrome_connection_id, 'sftp-port', ''),
        (chrome_connection_id, 'enable-wallpaper', 'false'),
        (chrome_connection_id, 'enable-theming', 'false'),
        (chrome_connection_id, 'enable-font-smoothing', 'true'),
        (chrome_connection_id, 'enable-full-window-drag', 'false'),
        (chrome_connection_id, 'enable-desktop-composition', 'false'),
        (chrome_connection_id, 'enable-menu-animations', 'false'),
        (chrome_connection_id, 'disable-bitmap-caching', 'false'),
        (chrome_connection_id, 'disable-offscreen-caching', 'false'),
        (chrome_connection_id, 'disable-glyph-caching', 'false'),
        (chrome_connection_id, 'preconnection-id', ''),
        (chrome_connection_id, 'console', 'false'),
        (chrome_connection_id, 'console-audio', 'false'),
        (chrome_connection_id, 'server-layout', 'en-us-qwerty'),
        (chrome_connection_id, 'timezone', 'America/New_York');
    
    -- Delete any existing permissions to avoid duplicates
    DELETE FROM guacamole_connection_permission 
    WHERE connection_id = chrome_connection_id 
    AND entity_id = admin_entity_id;
    
    -- Grant all permissions to the admin user
    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    VALUES
        (admin_entity_id, chrome_connection_id, 'READ'),
        (admin_entity_id, chrome_connection_id, 'UPDATE'),
        (admin_entity_id, chrome_connection_id, 'DELETE'),
        (admin_entity_id, chrome_connection_id, 'ADMINISTER');
END $$;

-- Verify admin permissions
DO $$
DECLARE
    admin_entity_id INT;
    admin_permissions INT;
BEGIN
    -- Get admin entity ID
    SELECT entity_id INTO admin_entity_id
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';
    
    -- Count admin permissions
    SELECT COUNT(*) INTO admin_permissions
    FROM guacamole_system_permission
    WHERE entity_id = admin_entity_id;
    
    -- Log the result
    RAISE NOTICE 'Admin user has % system permissions', admin_permissions;
    
    -- Count connection permissions
    SELECT COUNT(*) INTO admin_permissions
    FROM guacamole_connection_permission
    WHERE entity_id = admin_entity_id;
    
    -- Log the result
    RAISE NOTICE 'Admin user has % connection permissions', admin_permissions;
END $$;
