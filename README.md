# monero-node-windows-strict
Monero Node and Mining Strict stats
# Monero Node + XMRig Strict-Mode (Windows)

This repository contains a fully hardened, strict-mode configuration for running:

- **Monero full node (monerod.exe)**
- **XMRig CPU miner**
- **Daily SNS Status Reporting**
- **Self-healing services using NSSM**
- **Strict-mode protections so nothing changes unless the operator intends it**

Designed for Windows 10/11 systems using:
`D:\Monero-CLI` as the deployment directory.

---

## 🔒 Strict-Mode Philosophy

Everything in this repo follows strict rules:

1. No hidden features  
2. No automatic changes outside operator intent  
3. No RPC credentials unless explicitly enabled  
4. No pruning unless explicitly enabled  
5. Local RPC only (`127.0.0.1:18081`)  
6. External DNS/p2p binding only if chosen  
7. All monitoring is opt-in and transparent  
8. Services auto-restart but never self-modify  

This prevents unexpected behavior and makes your node predictable.

---
# Monero Node + XMRig (Windows Strict-Mode Setup)

This repository contains the complete **Strict-Mode** Windows automation stack for running:

- A local Monero full node (monerod)
- XMRig CPU mining
- Daily health-status reporting
- Auto-restart monitoring
- Zero surprise settings
- SNS notifications (optional)

Designed for:
✔️ Security  
✔️ Stability  
✔️ Clean automation  
✔️ No unexpected defaults  

---

## 📦 What’s Included

### **1. Strict-Mode Services**
| Component | Description |
|----------|-------------|
| `StartMoneroService.ps1` | Launches monerod with hard-coded safe parameters |
| `StartXMRigService.ps1` | Starts XMRig CPU miner under strict rules |
| `DailyStatus.ps1` | Sends a daily email summary (via SNS) |
| `CleanupOldMoneroMonitors.ps1` | Removes legacy monitors/tasks |
| `install-nssm-services.ps1` | Installs services using NSSM |

---

## 📁 Folder Structure


## 📁 Folder Overview

### `/scripts`
Runs your node + miner + monitoring.

- **StartMoneroService.ps1**  
  Launches the Monero daemon (monerod.exe) in strict mode.

- **StartXMRigService.ps1**  
  Launches XMRig with strict-mode config.json.

- **DailyStatus.ps1**  
  Sends a daily SNS report of node health, miner health, disk space, CPU load.

- **CleanupOldMoneroMonitors.ps1**  
  Removes legacy tasks/scripts that conflict with strict-mode setup.

---

### `/config`
- **config.json**  
  Fully optimized XMRig config for Ryzen 9 CPU, 60% load, TLS pool mining.

- **mining_pools.md**  
  Reference info for selecting alternative pools.

---

### `/services`
Install/uninstall scripts for easy NSSM deployment:

- `install_monero_service.ps1`  
- `install_xmrig_service.ps1`  
- `uninstall_all_services.ps1`

---

## 🚀 Installation

### 1. Clone the repo:
```powershell
git clone https://github.com/oreliousw/monero-node-windows-strict.git
monero-node-windows-strict/
│
├── README.md
├── .gitignore
│
├── scripts/
│   ├── StartMoneroService.ps1
│   ├── StartXMRigService.ps1
│   ├── DailyStatus.ps1
│   ├── CleanupOldMoneroMonitors.ps1
│
├── config/
│   ├── config.json          (XMRig)
│   └── mining_pools.md
│
└── services/
    ├── install_monero_service.ps1
    ├── install_xmrig_service.ps1
    └── uninstall_all_services.ps1

monero-node-windows-strict/
│
├── README.md                    # Keep as legacy Windows doc
├── archive/
│   └── windows/                 # All old PS scripts, NSSM, etc.
│
├── linux/
│   ├── README_linux.md          # New Linux documentation
│   ├── scripts/
│   │   ├── start_node.sh
│   │   ├── start_miner.sh
│   │   ├── stop_all.sh
│   │   ├── healthcheck.sh
│   │   └── send_sns.py          # Python SNS sender (optional)
│   │
│   ├── systemd/
│   │   ├── monerod-tmux.service
│   │   └── xmrig-tmux.service
│   │
│   ├── config/
│   │   ├── xmrig.json           # clean miner config template
│   │   └── monero.conf          # optional advanced flags
│   │
│   └── tools/
│       └── tmux_helpers.md      # cheat-sheet for tmux usage
│
└── .gitignore
