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
