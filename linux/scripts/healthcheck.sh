#!/bin/bash

LOGFILE="/var/log/monero_health.log"
NODE_SESSION="node"
MINER_SESSION="miner"
SNS_SCRIPT="/home/ubuntu/monero-node-tools/send_sns.py"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Health Check Running" >> $LOGFILE

# Check monerod tmux session
tmux has-session -t $NODE_SESSION 2>/dev/null
if [ $? != 0 ]; then
    python3 $SNS_SCRIPT "Monero Node DOWN" "monerod tmux session not running!"
    echo "monerod session missing" >> $LOGFILE
fi

# Check xmrig tmux session
tmux has-session -t $MINER_SESSION 2>/dev/null
if [ $? != 0 ]; then
    python3 $SNS_SCRIPT "XMRig DOWN" "xmrig tmux session not running!"
    echo "xmrig session missing" >> $LOGFILE
fi
