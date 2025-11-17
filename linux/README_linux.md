# Monero Node + XMRig (Linux VM Strict-Mode)

This directory contains the clean, hardened, production-ready Linux stack for running:

- Monero full node (monerod)
- XMRig miner
- tmux session management
- systemd autostart
- Health checks with SNS alerts

## Directory Overview
- `scripts/` – start/stop/healthcheck logic
- `systemd/` – autostart units
- `config/` – xmrig + monero configs
- `tools/` – tmux cheat sheet

## Setup

### 1. Install dependencies
```bash
sudo apt install tmux python3-pip -y
pip3 install boto3

2. Copy scripts:
sudo mkdir -p /home/ubuntu/monero-node-tools
sudo cp linux/scripts/*.sh /home/ubuntu/monero-node-tools/
sudo cp linux/scripts/*.py /home/ubuntu/monero-node-tools/
sudo chmod +x /home/ubuntu/monero-node-tools/*.sh

3. Enable systemd:
sudo cp linux/systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable monerod-tmux
sudo systemctl enable xmrig-tmux
sudo systemctl start monerod-tmux
sudo systemctl start xmrig-tmux

# ⭐ 5. Clean `.gitignore` for the repo

### `.gitignore`

Do not store blockchain data

bitmonero/
lmdb/
*.bin

Ignore compiled binaries

*.exe
xmrig
monerod

Python caches

pycache/

Logs

*.log
logs/

Temporary files

*.tmp
*.bak
