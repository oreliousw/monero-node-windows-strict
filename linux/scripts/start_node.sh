#!/bin/bash
SESSION="node"

tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION "cd /home/ubuntu/monero-node && ./monerod --data-dir /home/ubuntu/monero-node/bitmonero"
fi
