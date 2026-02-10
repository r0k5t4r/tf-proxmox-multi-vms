# OpenTofu Multi-VM Proxmox Deployment

This repository contains **OpenTofu (Terraform)** configurations for deploying **multiple virtual machine environments on Proxmox VE**.

It is designed to manage **multiple isolated environments** (Ceph, OpenStack, dev, prod, custom cloud-init setups) using:

- separate `.tfvars` files
- separate state files
- a shared, reusable OpenTofu module

---

## ✨ Features

- **Multiple Environment Support**  
  Deploy different environments using separate `.tfvars` files

- **Isolated State Management**  
  Each environment uses its own state file to avoid conflicts

- **Per-VM Cloud-Init Support (with Defaults)**  
  - Global default cloud-init  
  - Optional per-VM override via `cloud_init_name`  
  - Cloud-init configs are merged as *vendor data* (no loss of `ciuser`, `cipassword`, `sshkeys`)

- **Multi-Network & VLAN Support**  
  Multiple NICs per VM with VLAN tagging

- **Dynamic Disk Configuration**  
  Additional SCSI / VirtIO disks per VM (ideal for Ceph OSDs)

---

## 📋 Prerequisites

- **OpenTofu**  
  https://opentofu.org/

- **Proxmox VE** with:
  - API access
  - optional SSH access (for cloud-init snippet upload)

- **Cloud-init enabled VM template**  
  Guide:  
  https://www.roksblog.de/automating-vm-deployment-in-proxmox-using-opentofu-and-cloud-init-pt-1/

- **SSH public keys** (mandatory)

---

## 🔑 SSH Key Configuration (Important)

You **must** provide an `ssh_keys.txt` file.  
It will be injected into all VMs via cloud-init.

Example:

```bash
cat > ssh_keys.txt << 'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@host
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... user@host
EOF
```

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/r0k5t4r/tf-proxmox-multi-vms.git
cd tf-proxmox-multi-vms
```

### 2. Configure Proxmox Credentials

Copy and configure `terraform.tfvars` with your Proxmox API credentials:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials
```

Contents should include:
```hcl
proxmox_api_url          = "https://PROXMOX:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "your-token-secret"
proxmox_node             = "pve"
sshuser                  = "root"
sshpass                  = "your-password"
```

### 3. Initialize OpenTofu

```bash
tofu init --lock=false
```

> **Note**  
> Use `--lock=false` when working on SMB/NFS shares that do not support file locking.

---

## 🔧 Environment Configuration

Environment definitions are stored in the `environments/` directory.

Examples:
- `ceph.tfvars`
- `openstack-allinone.tfvars`
- `openstack-multinode-dev.tfvars`
- `dev.tfvars`
- `prod.tfvars`

Each environment file defines only **environment-specific settings**:

```hcl
# Environment-specific config (NOT Proxmox credentials)
vm_template  = "rocky-9-ci-template"
storage      = "zfs_vms"

vms = [
  {
    name       = "dev-web-server"
    vmid       = 99100
    # ... VM config
  }
]
```

Proxmox credentials come from `terraform.tfvars` (shared across all environments).

Before deploying, ensure in your chosen `.tfvars` file:

```hcl

---

## 📦 State Management

Each environment uses its own state file.

Backup example:

```bash
tofu state pull > backup.tfstate.backup
```

---

## 📤 Outputs

```bash
tofu output -state="ceph.tfstate"
```

Common outputs:
- `vm_ips`
- `vm_details`
- `ssh_commands`
- `vm_additional_disks`

---

## 📁 Repository Structure

```
.
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── cloud-init.tf
├── ssh_keys.txt
├── environments/
│   ├── ceph.tfvars
│   ├── openstack-allinone.tfvars
│   ├── openstack-multinode-dev.tfvars
│   ├── openstack-multinode.tfvars
│   ├── dev.tfvars
│   └── prod.tfvars
├── *.tfstate
└── README.md
```

---

## 🛠 Troubleshooting

### State Locking Errors

Use `--lock=false` on SMB/NFS shares.

### macOS permission denied on SMB/NFS shares

When running OpenTofu on macOS from SMB/NFS shares, provider binaries cannot be executed due to `noexec` mounts.

**Solution: Use a local plugin cache**

```bash
mkdir -p ~/.terraform.d/plugin-cache
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
rm -rf .terraform .terraform.lock.hcl
tofu init
```

Provider binaries will be executed locally while the project remains on the network share.

### `/etc/hosts` Reset on Reboot

Cloud-init regenerates `/etc/hosts`.

Disable by setting in `/etc/cloud/cloud.cfg`:

```yaml
manage_etc_hosts: false
```

Then run:

```bash
sudo cloud-init clean
sudo cloud-init init
```

---

## 🧪 Useful Commands

```bash
tofu validate
tofu fmt
tofu show -state="environment.tfstate"
tofu state list -state="environment.tfstate"
```

---

## 🤝 Contributing

1. Fork the repository  
2. Create a feature branch  
3. Test your changes  
4. Submit a pull request  

---

## 📜 License

Add your license information here.
