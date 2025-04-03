# All-in-One Guacamole Solution

This document explains how to use the all-in-one Guacamole solution with the linuxserver/guacamole image.

## Overview

After multiple attempts to resolve connectivity issues between separate Guacamole and Chrome VNC containers, we're providing an alternative all-in-one solution that eliminates container networking problems by combining Guacamole and VNC in a single container.

## Features

- Single container solution (no networking issues between containers)
- Built-in VNC server
- Pre-configured for immediate use
- Supports Chrome browser
- Supports audio streaming
- Simple configuration

## Usage Instructions

1. Navigate to the repository directory:
   ```
   cd /path/to/Guacamole
   ```

2. Start the all-in-one Guacamole container:
   ```
   docker-compose -f docker-compose-all-in-one.yaml up -d
   ```

3. Access Guacamole at:
   ```
   http://localhost:5000/
   ```

4. Default login credentials:
   - Username: `guacadmin`
   - Password: `guacadmin`

5. After logging in, you can create new connections or use the pre-configured ones.

## Configuration

The all-in-one solution uses the linuxserver/guacamole image which includes:

- Guacamole web application
- Guacamole daemon (guacd)
- Built-in VNC server
- Pre-configured connections

All configuration is stored in the guacamole_config volume, which persists between container restarts.

## Advantages Over Previous Approach

- Eliminates all networking issues between containers
- No need to configure VNC connections manually
- Simpler setup with fewer components
- More reliable connectivity
- Easier to maintain

## Notes

- This solution replaces the previous multi-container setup
- All data is stored in the guacamole_config volume
- The container exposes port 8080 (mapped to 5000 on the host)
