# Guacamole Docker with PostgreSQL Backend and VNC Support

This repository contains a Docker Compose setup for Apache Guacamole with PostgreSQL backend and VNC support.

## Features

- Apache Guacamole web application
- Guacamole daemon (guacd) with VNC protocol support
- PostgreSQL database for authentication and connection storage
- Complete initialization scripts for the database
- Configuration files for Guacamole
- Integrated Chrome browser accessible via VNC
- Automatic admin permissions setup

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/abhinavasr/Guacamole.git
   cd Guacamole
   ```

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. Access Guacamole at http://localhost:5000/guacamole/

4. Login with default credentials:
   - Username: `guacadmin`
   - Password: `guacadmin`

5. To connect to the Chrome browser:
   - Go to Settings > Connections
   - Click "New Connection"
   - Fill in the following:
     - Name: Chrome Browser
     - Protocol: VNC
     - Hostname: chrome
     - Port: 5900
     - Password: passwd
   - Click "Save"
   - Go back to Home and click on your new Chrome connection

## Production Deployment Notes

When deploying in production:

1. The setup automatically grants admin permissions to the guacadmin user
2. If deploying behind a reverse proxy, ensure your proxy is configured to pass the correct path (/guacamole/)
3. For security, change all default passwords after initial setup
4. If you're using a domain (like car.abhinava.xyz), access Guacamole at https://your-domain.com/guacamole/

### Troubleshooting Production Deployments

If you don't see the Settings option in the top-right menu:
- The initialization script should automatically grant admin permissions
- If issues persist, you can manually run the permissions fix:
  ```bash
  cat init/04-fix-permissions.sql | docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db
  docker restart guacamole-web
  ```

## Docker Commands Reference

### Basic Commands

- **Start all containers**:
  ```bash
  docker-compose up -d
  ```

- **Stop all containers**:
  ```bash
  docker-compose down
  ```

- **Stop and remove all containers and volumes** (clean start):
  ```bash
  docker-compose down -v
  ```

- **View container logs**:
  ```bash
  # View logs for a specific container
  docker logs guacamole-web
  docker logs guacamole-postgres
  docker logs guacamole-daemon
  docker logs guacamole-init-db
  docker logs guacamole-chrome
  
  # Follow logs in real-time
  docker logs -f guacamole-web
  ```

- **Check container status**:
  ```bash
  docker-compose ps
  ```

### Troubleshooting Commands

- **Monitor initialization process**:
  ```bash
  docker logs guacamole-init-db
  ```
  
- **Restart a specific container**:
  ```bash
  docker-compose restart guacamole-web
  ```

- **Access PostgreSQL database**:
  ```bash
  docker exec -it guacamole-postgres psql -U guacamole_user -d guacamole_db
  ```

- **Check network connectivity between containers**:
  ```bash
  docker exec -it guacamole-web ping postgres
  docker exec -it guacamole-web ping guacd
  docker exec -it guacamole-web ping chrome
  ```

## Understanding Initialization Logs

When running the initialization container, you may see errors like:
```
ERROR: relation "guacamole_user" already exists
ERROR: duplicate key value violates unique constraint
```

These errors are normal and expected when running the initialization scripts multiple times. They indicate that:
1. The database was already initialized in a previous run
2. The tables and objects already exist
3. The scripts are trying to create them again

As long as the initialization completes with "Schema initialization completed successfully", Guacamole will work properly.

## Chrome Browser Container

The integrated Chrome browser container provides a full Chrome/Chromium browser accessible via VNC through Guacamole.

### Chrome Container Details

- **Container name**: guacamole-chrome
- **Default resolution**: 1280x720
- **VNC port**: 5900
- **Default credentials**:
  - Username: user
  - Password: passwd
  - VNC Password: passwd

### Customizing Chrome Container

You can customize the Chrome container by modifying the environment variables in the docker-compose.yaml file:

```yaml
chrome:
  image: nkpro/chrome-vnc:latest
  environment:
    - RESOLUTION=1920x1080x24  # Change resolution
```

## Setting Up VNC Connections

After logging in to Guacamole:

1. Go to Settings > Connections
2. Click "New Connection"
3. Fill in the following:
   - Name: (any name for your connection)
   - Protocol: VNC
   - Hostname: (IP address of your VNC server)
   - Port: 5900 (default VNC port)
   - Password: (your VNC password)
4. Click "Save"

## Security Notice

For production use, please change the default passwords in:
- `docker-compose.yaml` (PostgreSQL passwords)
- After first login, change the default Guacamole admin password
- Change the default Chrome container VNC password

## License

This project is licensed under the Apache License 2.0.
