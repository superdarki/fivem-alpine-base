#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Create FIFO if it doesn't exist
FIFO=/tmp/console.pipe
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Trap exit signals to clean up
cleanup() {
    echo -e "FXServer exited. Cleaning up..."
    rm -f "$FIFO"
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# Start FXServer directly using exec so it replaces the shell process
tail -f "$FIFO" | sh -c "exec $MODIFIED_STARTUP" &
FX_PID=$!

# Input loop
while kill -0 "$FX_PID" 2>/dev/null; do
    if read -r -t 1 line; then
        echo "$line" > "$FIFO"
    fi
done