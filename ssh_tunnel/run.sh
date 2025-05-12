#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "Starting SSH tunnel..."

# Look at all the options
cat /data/options.json

# Ensure ~/.ssh exists and is linked to the config folder version
mkdir -p /root/.ssh
cp -r /config/.ssh/* /root/.ssh/
chown -R root:root /root/.ssh
chmod 600 /root/.ssh/* 2>/dev/null
chmod 644 /root/.ssh/*.pub 2>/dev/null


SSH_HOST=$(bashio::config 'ssh_host')
REMOTE_PORT=$(bashio::config 'remote_port' 8123)

echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel starting to $SSH_HOST (remote port: $REMOTE_PORT → local port: 8123)"

while true; do
    autossh -M 0 -N -R ${REMOTE_PORT}:localhost:8123 ${SSH_HOST} 2>&1
    echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel disconnected; retrying..."
    sleep 10
done
