#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

echo "Starting SSH tunnel..."

# Write the private SSH key to a temporary file
PRIVATE_SSH_KEY=$(bashio::config 'private_ssh_key')
if [ -n "$PRIVATE_SSH_KEY" ]; then
    echo "$PRIVATE_SSH_KEY" > /tmp/ssh_key
    chmod 600 /tmp/ssh_key
    SSH_IDENTITY="/tmp/ssh_key"
else
    echo "Error: private_ssh_key is not set in the configuration."
    exit 1
fi

SSH_HOST=$(bashio::config 'ssh_host')
REMOTE_PORT=$(bashio::config 'remote_port' 8123)
LOCAL_HOST=$(bashio::config 'local_host' 'localhost')
LOCAL_PORT=$(bashio::config 'local_port' 8123)
SSH_USER=$(bashio::config 'ssh_user' 'homeassistant')
OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options' '')

echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel starting to $SSH_HOST (remote port: $REMOTE_PORT → $LOCAL_HOST:$LOCAL_PORT) as $SSH_USER"

while true; do
    # check to see if the host is reachable by doing a keyscan
    # if it is not reachable, wait 10 seconds and try again
    if ! ssh-keyscan -t ed25519 "$SSH_HOST" > /root/.ssh/known_hosts 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Host $SSH_HOST is not reachable; retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # assure the permissions are correct
    chmod 600 /root/.ssh/known_hosts
    
    eval autossh -M 0 -N -R ${REMOTE_PORT}:${LOCAL_HOST}:${LOCAL_PORT} \
        -i ${SSH_IDENTITY} \
        ${OTHER_SSH_OPTIONS} \
        ${SSH_USER}@${SSH_HOST} 2>&1
    EXIT_CODE=$?
    echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel disconnected; retrying..."

    if [ $EXIT_CODE -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel exited with code $EXIT_CODE; retrying..."
    fi
    sleep 10
done