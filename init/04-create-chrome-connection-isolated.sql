--
-- Create Chrome VNC connection
--

INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('Chrome Browser', 'vnc');

-- Get the connection_id for the Chrome connection
DO $$
DECLARE
    chrome_connection_id INT;
BEGIN
    SELECT connection_id INTO chrome_connection_id
    FROM guacamole_connection
    WHERE connection_name = 'Chrome Browser';

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
        (chrome_connection_id, 'autoretry', '10');

    -- Grant access to the admin user
    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT entity_id, chrome_connection_id, 'READ'
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';

    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT entity_id, chrome_connection_id, 'UPDATE'
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';

    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT entity_id, chrome_connection_id, 'DELETE'
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';

    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT entity_id, chrome_connection_id, 'ADMINISTER'
    FROM guacamole_entity
    WHERE name = 'guacadmin' AND type = 'USER';
END $$;
