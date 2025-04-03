--
-- Create default Chrome connection
--

-- Create a connection for Chrome Browser
INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('Chrome Browser', 'vnc');

-- Get the connection_id for the Chrome Browser connection
DO $$
DECLARE
    chrome_connection_id integer;
BEGIN
    SELECT connection_id INTO chrome_connection_id
    FROM guacamole_connection
    WHERE connection_name = 'Chrome Browser';

    -- Add the required parameters for the Chrome Browser connection
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
        (chrome_connection_id, 'hostname', 'chrome'),
        (chrome_connection_id, 'port', '5901'),
        (chrome_connection_id, 'password', 'passwd'),
        (chrome_connection_id, 'color-depth', '24'),
        (chrome_connection_id, 'cursor', 'local'),
        (chrome_connection_id, 'swap-red-blue', 'false'),
        (chrome_connection_id, 'read-only', 'false'),
        (chrome_connection_id, 'enable-audio', 'true'),
        (chrome_connection_id, 'resize-method', 'display-update'),
        (chrome_connection_id, 'security', 'any'),
        (chrome_connection_id, 'ignore-cert', 'true'),
        (chrome_connection_id, 'autoretry', '10'),
        (chrome_connection_id, 'clipboard-encoding', 'UTF-8');

    -- Grant access to the admin user
    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT
        entity_id,
        chrome_connection_id,
        permission
    FROM (
        VALUES
            ('guacadmin', 'READ'),
            ('guacadmin', 'UPDATE'),
            ('guacadmin', 'DELETE'),
            ('guacadmin', 'ADMINISTER')
    ) permissions (username, permission)
    JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER';
END $$;
