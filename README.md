# OpenTofu Multi-VM Proxmox Deployment

This repository contains **OpenTofu (Terraform)** configurations for deploying **multiple virtual machine environments on Proxmox VE**.

It is designed to manage **multiple isolated environments** (Ceph, OpenStack, dev, prod, custom cloud-init setups) using:

- separate `.tfvars` files
- separate state files
- a shared, reusable OpenTofu module

---

## ✨ Features

- **Multiple Environment Support**  
  Deploy different environments using separate `.tfvars` files (Ceph, OpenStack, dev, prod, etc.)

- **Isolated State Management**  
  Each environment uses its own state file to avoid conflicts

- **Per-VM Cloud-Init Support (with Defaults)**  
  - Global default cloud-init  
  - Optional per-VM cloud-init override  
  - Cloud-init configs are merged (vendor data), so `ciuser`, `cipassword`, and `sshkeys` are preserved

- **Multi-Network & VLAN Support**  
  Attach multiple NICs per VM with VLAN tagging

- **Dynamic Disk Configuration**  
  Add additional SCSI / VirtIO disks per VM (ideal for Ceph OSDs)

- **Consistent VM Definitions**  
  All environments share the same schema, making them easy to compare and maintain

---

## 📋 Prerequisites

- **OpenTofu** installed  
  https://opentofu.org/

- **Proxmox VE** cluster with:
  - API access
  - optional SSH access (used to upload cloud-init snippets)

- **Cloud-Init–enabled VM template**  
  Follow this guide to prepare one:  
  https://www.roksblog.de/automating-vm-deployment-in-proxmox-using-opentofu-and-cloud-init-pt-1/

- **SSH public keys** for VM access

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/r0k5t4r/tf-proxmox-multi-vms.git
cd tf-proxmox-multi-vms
```

### 2. Initialize OpenTofu

```bash
tofu init --lock=false
```

> **Note**  
> Use `--lock=false` when working on SMB/NFS shares that do not support file locking.

---

## 🔧 Cloud-Init Model

- A **default cloud-init file** is used for all VMs
- Individual VMs may override it using:

```hcl
cloud_init_name = "cephadm-cloud-init.yaml"
```

- Cloud-init configs are injected as **vendor data**, so base users and SSH keys remain intact

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

## 📜 License

Add your license information here.
