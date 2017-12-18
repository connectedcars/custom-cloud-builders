#!/bin/bash

set -e

if [[ ! -n "$SSH_KEY_PASSWORD" ]]; then
    echo "SSH_KEY_PASSWORD needs to be set"
    exit 255
fi

# Start ssh-agent and set a trap to kill it when we exit the script
eval "$(ssh-agent)" > /dev/null
trap 'ssh-agent -k > /dev/null' EXIT

/usr/local/bin/ssh-add.sh /root/.ssh/id_rsa || (echo "ssh-add failed with error code: $?" && exit 1)
unset SSH_KEY_PASSWORD

echo "Loaded keys:"
ssh-add -l

exec npm $@