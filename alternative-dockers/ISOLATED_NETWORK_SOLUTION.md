# Guacamole Isolated Network Solution

This document explains the isolated network solution implemented to fix VNC connectivity issues in Guacamole while ensuring no impact on other Docker applications.

## Problem Summary

The original Guacamole setup was experiencing persistent VNC connectivity issues with the error:
```
guacd[22]: ERROR: Unable to connect to VNC server.
```

Previous attempts to fix this using host network mode were unsuccessful and risked interfering with other Docker applications.

## Solution: Isolated Network Approach

The new solution uses an isolated bridge network with a custom subnet that won't conflict with other Docker applications. This approach:

1. Creates a dedicated bridge network for Guacamole components
2. Uses container names for service discovery instead of localhost
3. Only exposes the necessary port (5000) for accessing the Guacamole web interface
4. Configures VNC with enhanced connection parameters for reliability

## Key Components

1. **Custom Bridge Network**:
   - Named `guacamole_internal` to avoid conflicts
   - Uses subnet `172.28.0.0/16` which is unlikely to conflict with other networks
   - Isolates all Guacamole services within this network

2. **Enhanced VNC Connection Parameters**:
   - Security set to 'none' to eliminate authentication issues
   - Ignore-cert set to 'true' to bypass certificate validation
   - Autoretry set to '10' for automatic reconnection attempts
   - Longer startup delay (45 seconds) to ensure VNC server is fully initialized

3. **Minimal Port Exposure**:
   - Only port 5000 is exposed to the host for the Guacamole web interface
   - All other services communicate internally within the isolated network

## How to Use

1. Run the start script:
   ```
   chmod +x start-isolated-mode.sh
   ./start-isolated-mode.sh
   ```

2. Access Guacamole at http://localhost:5000/
   - Username: guacadmin
   - Password: guacadmin

3. The Chrome browser connection will be automatically created and available on the home screen.

## Advantages Over Previous Solutions

1. **No Impact on Other Docker Apps**: Unlike host network mode, this solution won't interfere with other Docker applications running on your system.

2. **Improved Security**: Services are isolated in their own network, reducing exposure.

3. **Simplified Configuration**: Uses standard Docker networking patterns for service discovery.

4. **Enhanced Reliability**: Includes connection retry mechanisms and proper initialization delays.

## Troubleshooting

If you still experience issues:
1. Check container logs: `docker logs guacamole-daemon`
2. Verify all containers are running: `docker ps`
3. Run the diagnostic script: `./host-diagnostic.sh`
