#!/bin/ash
# Copyright (c) 2021 Matthew Penner
# Licensed under the MIT License (see original script for full terms)

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Convert all of the "{{VARIABLE}}" parts of the command into shell variable format
PARSED=$(eval echo "$(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g')")

# Debug the parsed command
echo -e "\033[1m\033[33mcontainer@pelican~ \033[0m$PARSED"

# Create FIFO if it doesn't exist
FIFO=/tmp/console.pipe
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Start the server with redirected input from the FIFO
# Use tail -f to keep reading from it, and forward to FXServer
tail -f "$FIFO" | $PARSED &

# Keep reading from stdin and forward user input into FIFO
# This allows command input from Pterodactyl to reach the FXServer
while IFS= read -r line; do
  echo "$line" > "$FIFO"
done
