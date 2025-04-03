#!/bin/bash

echo "=== VNC Connectivity Diagnostic Script ==="
echo "This script will help diagnose VNC connectivity issues between Guacamole and Chrome containers"
echo ""

# Check if the Chrome container is running
echo "=== Checking if Chrome container is running ==="
docker ps | grep chrome
if [ $? -ne 0 ]; then
  echo "ERROR: Chrome container is not running!"
  exit 1
fi
echo ""

# Check if VNC port is open in Chrome container
echo "=== Checking if VNC port is open in Chrome container ==="
docker exec chrome nc -zv localhost 5901
if [ $? -ne 0 ]; then
  echo "ERROR: VNC port 5901 is not open in Chrome container!"
else
  echo "SUCCESS: VNC port 5901 is open in Chrome container"
fi
echo ""

# Check if guacd container can reach Chrome container
echo "=== Checking if guacd container can reach Chrome container ==="
docker exec guacamole-daemon ping -c 3 chrome
if [ $? -ne 0 ]; then
  echo "ERROR: guacd container cannot reach Chrome container!"
else
  echo "SUCCESS: guacd container can reach Chrome container"
fi
echo ""

# Check if guacd container can reach Chrome VNC port
echo "=== Checking if guacd container can reach Chrome VNC port ==="
docker exec guacamole-daemon nc -zv chrome 5901
if [ $? -ne 0 ]; then
  echo "ERROR: guacd container cannot reach Chrome VNC port!"
else
  echo "SUCCESS: guacd container can reach Chrome VNC port"
fi
echo ""

# Check if host can reach Chrome VNC port
echo "=== Checking if host can reach Chrome VNC port ==="
nc -zv localhost 5901
if [ $? -ne 0 ]; then
  echo "ERROR: Host cannot reach Chrome VNC port!"
else
  echo "SUCCESS: Host can reach Chrome VNC port"
fi
echo ""

# Check VNC process in Chrome container
echo "=== Checking VNC process in Chrome container ==="
docker exec chrome ps aux | grep vnc
echo ""

# Check Chrome container logs
echo "=== Checking Chrome container logs ==="
docker logs chrome | tail -n 20
echo ""

# Check guacd logs
echo "=== Checking guacd logs ==="
docker logs guacamole-daemon | tail -n 20
echo ""

echo "=== Diagnostic Complete ==="
echo "Please share the output of this script for further troubleshooting"
