#!/bin/bash
SESSION="miner"

tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION "cd /home/ubuntu/xmrig/build && ./xmrig"
fi
