# VNC Connection Configuration for Guacamole

# This file contains sample VNC connection configurations for Guacamole
# You can use these as templates when creating connections through the Guacamole web interface

## Basic VNC Connection Parameters
# hostname: The hostname or IP address of the VNC server
# port: The port the VNC server is listening on (default is 5900)
# password: The password for the VNC server
# color-depth: The color depth in bits per pixel (8, 16, 24, 32)
# swap-red-blue: Whether to swap red and blue components of each color

## Example VNC Connection
# Name: Example VNC Server
# Protocol: VNC
# Parameters:
#   hostname: vnc-server
#   port: 5900
#   password: vncpassword
#   color-depth: 24
#   swap-red-blue: false
#   cursor: local
#   read-only: false

## Additional VNC Parameters
# cursor: The cursor type to use (local, remote)
# read-only: Whether the connection should be read-only
# clipboard-encoding: The encoding to use for clipboard transfers
# dest-host: The destination host to connect to if using a proxy
# dest-port: The destination port to connect to if using a proxy
# recording-path: The path to save session recordings
# recording-name: The name pattern to use for recordings
# recording-exclude-output: Whether to exclude graphical output from recordings
# recording-exclude-mouse: Whether to exclude mouse events from recordings
# recording-include-keys: Whether to include key events in recordings
