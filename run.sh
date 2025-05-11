#!/bin/bash

SSH_USER="${1:-your_ssh_user}"
SSH_HOST="${2:-your.public.server.com}"
SSH_PKEY="${3:-/path/to/your/private/key}"
SSH_PORT="${4:-8123}"

while true; do
    autossh -M 0 -N -R ${REMOTE_PORT}:localhost:${LOCAL_PORT} ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT}
    sleep 10
done
