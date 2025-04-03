# Guacamole Docker with PostgreSQL Backend and VNC Support

This repository contains a Docker Compose setup for Apache Guacamole with PostgreSQL backend and VNC support.

## Features

- Apache Guacamole web application
- Guacamole daemon (guacd) with VNC protocol support
- PostgreSQL database for authentication and connection storage
- Complete initialization scripts for the database
- Configuration files for Guacamole

## Quick Start

1. Clone this repository
2. Run `docker-compose up -d`
3. Access Guacamole at http://localhost:5000/guacamole/
4. Login with default credentials:
   - Username: `guacadmin`
   - Password: `guacadmin`

## Security Notice

For production use, please change the default passwords in:
- `docker-compose.yaml` (PostgreSQL passwords)
- After first login, change the default Guacamole admin password

## Documentation

See the [README.md](README.md) file for complete documentation.

## License

This project is licensed under the Apache License 2.0.
