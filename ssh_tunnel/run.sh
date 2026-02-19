#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -x
echo "Starting SSH tunnel..."

SSH_HOST=$(bashio::config 'ssh_host')
SSH_USER=$(bashio::config 'ssh_user' 'homeassistant')
SSH_KEY_PATH=$(bashio::config 'ssh_key_path')

LOCAL_FWD_HOST="127.0.0.1"
REMOTE_BIND_HOST="127.0.0.1"
SSH_DIR="/config/ssh_tunnel_ssh"
KNOWN_HOSTS="$SSH_DIR/known_hosts"

# Don't wait before restarting
export AUTOSSH_GATETIME=0
export AUTOSSH_POLL=30
export AUTOSSH_FIRST_POLL=30

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

    # assure the permissions are correct
    chmod 600 /root/.ssh/known_hosts

    echo "Starting autossh"

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
        -o ConnectTimeout=10 \
        -o BatchMode=yes \
        -o TCPKeepAlive=yes \
        -o ExitOnForwardFailure=yes \
        -o UserKnownHostsFile=$KNOWN_HOSTS \
        -o StrictHostKeyChecking=yes \
        "${SSH_USER}@${SSH_HOST}" 2>&1
    EXIT_CODE=$?
    echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel disconnected; retrying..."

    if [ $EXIT_CODE -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Tunnel exited with code $EXIT_CODE; retrying..."
    fi
    sleep 10
done