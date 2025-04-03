# Changes Made to Guacamole Configuration

## Overview
This document outlines the changes made to the Guacamole configuration to:
1. Set Chrome as the default connection
2. Enable audio streaming for VNC connections

## Files Modified

### 1. `config/guacamole.properties`
- Added `default-landing-uri: /guacamole/#/client/c/Chrome%20Browser` to set Chrome as the default connection
- Added audio streaming configuration:
  ```
  # Audio settings
  # Enable audio streaming for VNC connections
  vnc-enable-audio: true
  vnc-audio-servername: chrome
  ```

### 2. `docker-compose.yaml`
- Added audio support to the Chrome container:
  ```yaml
  environment:
    - RESOLUTION=1280x720x24
    - ENABLE_AUDIO=true
    - PULSE_SERVER=127.0.0.1
  ```
- Added a persistent volume for Chrome data:
  ```yaml
  volumes:
    - chrome_data:/home/user/data
  ```
- Added volume definition:
  ```yaml
  volumes:
    postgres_data:
    chrome_data:
  ```
- Added volume mount for configuration in the guacamole container:
  ```yaml
  volumes:
    - ./config:/config
  ```
- Added GUACAMOLE_HOME environment variable:
  ```yaml
  environment:
    GUACAMOLE_HOME: /config
  ```
- Added reference to the new SQL file for Chrome connection:
  ```yaml
  volumes:
    - ./init/04-create-chrome-connection.sql:/schema/04-create-chrome-connection.sql
  ```

### 3. Created New File: `init/04-create-chrome-connection.sql`
- Created a SQL script to automatically create a Chrome connection with audio enabled
- Connection parameters include:
  - hostname: chrome
  - port: 5900
  - password: passwd
  - color-depth: 24
  - enable-audio: true
  - audio-servername: chrome

### 4. Modified `init/init-db.sh`
- Updated to include the new SQL file in the initialization process:
  ```bash
  PGPASSWORD=guacamole_password psql -h postgres -U guacamole_user -d guacamole_db -f /schema/04-create-chrome-connection.sql
  ```

## How These Changes Work

1. **Chrome as Default Connection**:
   - The `default-landing-uri` parameter in guacamole.properties redirects users to the Chrome connection upon login
   - The SQL script creates a Chrome connection in the database automatically during initialization

2. **Audio Streaming**:
   - VNC audio settings are enabled in guacamole.properties
   - The Chrome container is configured with audio support via environment variables
   - The connection parameters in the SQL script enable audio for the Chrome connection

## Testing
To test these changes:
1. Start the Guacamole stack with `docker-compose up -d`
2. Access the Guacamole web interface at http://localhost:5000/
3. You should be automatically directed to the Chrome connection
4. Audio from the Chrome browser should be streamed to your local device

## Notes
- The Chrome browser runs with a resolution of 1280x720
- Audio streaming requires proper PulseAudio configuration in the Chrome container
- The Chrome data is now persistent between container restarts
