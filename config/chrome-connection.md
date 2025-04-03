# Chrome Browser Connection Configuration

This file provides instructions for configuring a connection to the Chrome browser container in Guacamole.

## Connection Details

Use these settings when creating a new connection in Guacamole:

- **Name**: Chrome Browser
- **Protocol**: VNC
- **Hostname**: chrome
- **Port**: 5900
- **Password**: passwd
- **Color depth**: 24
- **Resize method**: display-update (recommended for best performance)

## Default Credentials

The Chrome browser container has the following default credentials:

- **Username**: user
- **Password**: passwd
- **VNC Password**: passwd

## Notes

- The Chrome browser runs in a container with a resolution of 1280x720
- You can change the resolution by modifying the RESOLUTION environment variable in docker-compose.yaml
- The browser persists no data between restarts
