#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

echo "Starting SSH tunnel..."

ls /config

SSH_HOST=$(bashio::config 'ssh_host')
REMOTE_PORT=$(bashio::config 'remote_port' 8123)
LOCAL_HOST=$(bashio::config 'local_host' 'localhost')
LOCAL_PORT=$(bashio::config 'local_port' 8123)
SSH_USER=$(bashio::config 'ssh_user' 'homeassistant')
OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options' '')
SSH_KEY_PATH=$(bashio::config 'ssh_key_path')

if [ -f "$SSH_KEY_PATH" ]; then
    chmod 600 "$SSH_KEY_PATH"
else
    echo "path to SSH key not found: $SSH_KEY_PATH"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel starting to $SSH_HOST (remote port: $REMOTE_PORT → $LOCAL_HOST:$LOCAL_PORT) as $SSH_USER"

# Make sure the .ssh directory exists and has the correct permissions
mkdir -p /root/.ssh
chmod 700 /root/.ssh

while true; do
    # check to see if the host is reachable by doing a keyscan
    # if it is not reachable, wait 10 seconds and try again
    echo "Scan keys"
    if ! ssh-keyscan -t ed25519 "$SSH_HOST" > /root/.ssh/known_hosts 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Host $SSH_HOST is not reachable; retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # assure the permissions are correct
    chmod 600 /root/.ssh/known_hosts

    eval autossh -M 0 -N -R ${REMOTE_PORT}:${LOCAL_HOST}:${LOCAL_PORT} \
        -n \
        -i ${SSH_KEY_PATH} \
        ${OTHER_SSH_OPTIONS} \
        ${SSH_USER}@${SSH_HOST} 2>&1
    EXIT_CODE=$?
    echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel disconnected; retrying..."

    if [ $EXIT_CODE -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel exited with code $EXIT_CODE; retrying..."
    fi
    sleep 10
done