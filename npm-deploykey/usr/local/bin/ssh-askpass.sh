#/bin/bash

# Make sure we are only called once
if [ ! -f "/tmp/ssh-askpass" ]; then
    echo $SSH_KEY_PASSWORD
    touch /tmp/ssh-askpass
    exit 0
else 
    exit 1
fi