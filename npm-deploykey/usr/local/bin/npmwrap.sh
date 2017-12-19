#!/bin/bash

set -e

if [[ ! -n "$SSH_KEY_PASSWORD" ]]; then
    echo "SSH_KEY_PASSWORD needs to be set"
    exit 255
fi

# Start ssh-agent and set a trap to kill it when we exit the script
eval "$(ssh-agent)" > /dev/null
trap 'ssh-agent -k > /dev/null' EXIT

# Load keys
for key in `ls -1 /root/.ssh/id_rsa*`; do
    if [[ "$key" == *.pub ]]; then
        # Skip pub key
        continue;
    fi
    
    if [ -f "$key" ]; then
        /usr/local/bin/ssh-add.sh $key || (echo "ssh-add failed with error code: $? for $key")
        rm -f /tmp/ssh-askpass
    fi
done
unset SSH_KEY_PASSWORD

echo "Loaded keys:"
ssh-add -l

exec npm $@