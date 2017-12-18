#/bin/bash
export DISPLAY=:0
export SSH_ASKPASS=/usr/local/bin/ssh-askpass.sh
exec 0>&- # close stdin
#exec 1>&- # close stdout
#exec 2>&- # close stderr
exec setsid ssh-add $@