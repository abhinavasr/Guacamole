# Guacamole Docker with PostgreSQL Backend and VNC Support

This repository contains a Docker Compose setup for Apache Guacamole with PostgreSQL backend and VNC support.

## Features

- Apache Guacamole web application
- Guacamole daemon (guacd) with VNC protocol support
- PostgreSQL database for authentication and connection storage
- Complete initialization scripts for the database
- Configuration files for Guacamole

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

## License

This project is licensed under the Apache License 2.0.
