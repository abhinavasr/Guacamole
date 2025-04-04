--
-- Create Chrome VNC connection with direct IP address
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

    -- Insert Chrome connection parameters with direct IP address
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
        (chrome_connection_id, 'hostname', 'CHROME_IP_ADDRESS'),
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
        (chrome_connection_id, 'read-only', 'false'),
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
