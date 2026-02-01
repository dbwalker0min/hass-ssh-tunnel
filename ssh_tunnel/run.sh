#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

echo "Starting SSH tunnel..."

SSH_HOST=$(bashio::config 'ssh_host')
LOCAL_FWD_HOST="127.0.0.1"
REMOTE_BIND_HOST="127.0.0.1"
SSH_USER=$(bashio::config 'ssh_user' 'homeassistant')
OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options' '')
SSH_KEY_PATH=$(bashio::config 'ssh_key_path')

if [ -f "$SSH_KEY_PATH" ]; then
    chmod 600 "$SSH_KEY_PATH"
else
    echo "path to SSH key not found: $SSH_KEY_PATH"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel starting to $SSH_HOST as $SSH_USER"

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

    echo "Starting autossh with ${OTHER_SSH_OPTIONS}"

    # This starts the autossh command forwarding the home assistant port and the pyscript kernel ports
    autossh -N \
        -R ${REMOTE_BIND_HOST}:8123:${LOCAL_FWD_HOST}:8123 \
        -R ${REMOTE_BIND_HOST}:50321:${LOCAL_FWD_HOST}:50321 \
        -R ${REMOTE_BIND_HOST}:50322:${LOCAL_FWD_HOST}:50322 \
        -R ${REMOTE_BIND_HOST}:50323:${LOCAL_FWD_HOST}:50323 \
        -R ${REMOTE_BIND_HOST}:50324:${LOCAL_FWD_HOST}:50324 \
        -R ${REMOTE_BIND_HOST}:50325:${LOCAL_FWD_HOST}:50325 \
        -R ${REMOTE_BIND_HOST}:50326:${LOCAL_FWD_HOST}:50326 \
        -R ${REMOTE_BIND_HOST}:50327:${LOCAL_FWD_HOST}:50327 \
        -R ${REMOTE_BIND_HOST}:50328:${LOCAL_FWD_HOST}:50328 \
        -R ${REMOTE_BIND_HOST}:50329:${LOCAL_FWD_HOST}:50329 \
        -R ${REMOTE_BIND_HOST}:50330:${LOCAL_FWD_HOST}:50330 \
        -R ${REMOTE_BIND_HOST}:50331:${LOCAL_FWD_HOST}:50331 \
        -R ${REMOTE_BIND_HOST}:50332:${LOCAL_FWD_HOST}:50332 \
        -R ${REMOTE_BIND_HOST}:50333:${LOCAL_FWD_HOST}:50333 \
        -R ${REMOTE_BIND_HOST}:50334:${LOCAL_FWD_HOST}:50334 \
        -R ${REMOTE_BIND_HOST}:50335:${LOCAL_FWD_HOST}:50335 \
        -R ${REMOTE_BIND_HOST}:50336:${LOCAL_FWD_HOST}:50336 \
        -R ${REMOTE_BIND_HOST}:50337:${LOCAL_FWD_HOST}:50337 \
        -R ${REMOTE_BIND_HOST}:50338:${LOCAL_FWD_HOST}:50338 \
        -R ${REMOTE_BIND_HOST}:50339:${LOCAL_FWD_HOST}:50339 \
        -n \
        -i "${SSH_KEY_PATH}" \
        -M 20000 \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=5 \
        -o ExitOnForwardFailure=yes \
        ${OTHER_SSH_OPTIONS} \
        "${SSH_USER}@${SSH_HOST}" 2>&1
    EXIT_CODE=$?
    echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel disconnected; retrying..."

    if [ $EXIT_CODE -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel exited with code $EXIT_CODE; retrying..."
    fi
    sleep 10
done