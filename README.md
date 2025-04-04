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
- Audio streaming support
- Comprehensive healthchecks and waiting logic for reliable deployment
- Direct IP-based connection for robust VNC connectivity

## Quick Start

### For Windows Users

1. Clone this repository:
   ```bash
   git clone https://github.com/abhinavasr/Guacamole.git
   cd Guacamole
   ```

2. Run the setup script:
   ```bash
   setup.bat
   ```

3. Access Guacamole at http://localhost:5000/

4. Login with default credentials:
   - Username: `guacadmin`
   - Password: `guacadmin`

### For Linux/Mac Users

1. Clone this repository:
   ```bash
   git clone https://github.com/abhinavasr/Guacamole.git
   cd Guacamole
   ```

2. Make initialization scripts executable:
   ```bash
   chmod +x init/*.sh
   ```

3. Start the containers:
   ```bash
   docker-compose up -d
   ```

4. Access Guacamole at http://localhost:5000/

5. Login with default credentials:
   - Username: `guacadmin`
   - Password: `guacadmin`

## Important Note About Script Permissions

If you're working across different operating systems or cloning this repository on a new system, you may need to ensure the initialization scripts are executable:

```bash
# Make all shell scripts in the init directory executable
chmod +x init/*.sh

# For Git to track the executable permission
git update-index --chmod=+x init/00-init-setup.sh
git update-index --chmod=+x init/init-db.sh
git update-index --chmod=+x init/prepare-db.sh
```

This is particularly important when switching between Windows and Linux/Mac environments, as Windows doesn't maintain the executable bit that Linux and Mac require for shell scripts.

## Key Improvements in This Solution

This optimized configuration includes several improvements:

- **Robust Healthchecks**: Comprehensive health monitoring for all services
- **Proper Service Dependencies**: Services start only when their dependencies are healthy
- **Database Readiness Checks**: Explicit polling to ensure database is fully ready before initialization
- **Dynamic IP Resolution**: Automatically discovers Chrome container's IP address for reliable VNC connectivity
- **Exposed Ports for Debugging**: Critical ports exposed for troubleshooting when needed
- **Enhanced Connection Parameters**: Optimized settings for better compatibility
- **Chrome as Default Connection**: Automatically set as the landing page
- **Audio Streaming Support**: Enabled for better user experience

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
  docker logs chrome
  
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

- **Check Chrome container IP address**:
  ```bash
  docker exec -it guacamole-init-db getent hosts chrome
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

As long as the initialization completes with "Database initialization completed successfully", Guacamole will work properly.

## Chrome Browser Container

The integrated Chrome browser container provides a full Chrome/Chromium browser accessible via VNC through Guacamole.

### Chrome Container Details

- **Container name**: chrome
- **Default resolution**: 1280x720
- **VNC port**: 5901
- **noVNC web client port**: 6901
- **Default credentials**:
  - Username: user
  - Password: passwd
  - VNC Password: passwd

### Customizing Chrome Container

You can customize the Chrome container by modifying the environment variables in the docker-compose.yaml file:

```yaml
chrome:
  environment:
    - VNC_RESOLUTION=1920x1080  # Change resolution
```

## Direct VNC Access (For Testing)

For troubleshooting purposes, you can access the VNC server directly:

- **VNC client**: localhost:5901 (password: passwd)
- **noVNC web client**: http://localhost:6901 (password: passwd)

## Security Notice

For production use, please change the default passwords in:
- `docker-compose.yaml` (PostgreSQL passwords)
- After first login, change the default Guacamole admin password
- Change the default Chrome container VNC password

## Alternative Solutions

This repository includes several alternative Docker configurations in the `alternative-dockers` folder for specific use cases:

- **Host Network Mode**: For environments where container networking is problematic
- **Isolated Network**: For environments where isolation from other Docker apps is critical
- **Simplified Configuration**: A more basic setup with fewer dependencies
- **All-in-One Solution**: A single container approach for simpler deployments

Each alternative includes its own documentation and startup scripts.

## Production Deployment Notes

When deploying in production:

1. The setup automatically grants admin permissions to the guacadmin user
2. If deploying behind a reverse proxy, ensure your proxy is configured to pass the correct path (/guacamole/)
3. For security, change all default passwords after initial setup
4. If you're using a domain (like car.abhinava.xyz), access Guacamole at https://your-domain.com/guacamole/

## License

This project is licensed under the Apache License 2.0.
