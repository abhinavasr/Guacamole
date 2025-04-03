--
-- Cleanup script to remove duplicate Chrome connections
--

-- First, identify all Chrome Browser connections
DO $$
DECLARE
    connection_count integer;
BEGIN
    -- Count how many Chrome Browser connections exist
    SELECT COUNT(*) INTO connection_count
    FROM guacamole_connection
    WHERE connection_name = 'Chrome Browser';
    
    -- If more than one Chrome Browser connection exists, keep only the newest one
    IF connection_count > 1 THEN
        -- Delete all but the newest Chrome Browser connection
        DELETE FROM guacamole_connection
        WHERE connection_name = 'Chrome Browser'
        AND connection_id NOT IN (
            SELECT connection_id
            FROM guacamole_connection
            WHERE connection_name = 'Chrome Browser'
            ORDER BY connection_id DESC
            LIMIT 1
        );
        
        RAISE NOTICE 'Removed % duplicate Chrome Browser connections', connection_count - 1;
    END IF;
    
    -- Check if guacamole-chrome connection exists
    SELECT COUNT(*) INTO connection_count
    FROM guacamole_connection
    WHERE connection_name = 'guacamole-chrome';
    
    -- If guacamole-chrome connection exists, remove it
    IF connection_count > 0 THEN
        DELETE FROM guacamole_connection
        WHERE connection_name = 'guacamole-chrome';
        
        RAISE NOTICE 'Removed guacamole-chrome connection';
    END IF;
END $$;
