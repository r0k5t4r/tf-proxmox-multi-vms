# OpenTofu Multi-VM Proxmox Deployment

This repository contains OpenTofu (Terraform) configuration for deploying multiple VM environments on Proxmox VE. It supports deploying different setups (CEPH, OpenStack, development, etc.) using separate configuration files and state management.

## Features

- **Multiple Environment Support**: Deploy different VM configurations using separate `.tfvars` files
- **Isolated State Management**: Each environment uses its own state file
- **Dynamic Disk Configuration**: Support for additional disks (SCSI/VirtIO) for storage nodes
- **Multi-Network Support**: Configure multiple network interfaces with VLAN support
- **Cloud-Init Integration**: Automated VM provisioning with SSH key management

## Prerequisites

- [OpenTofu](https://opentofu.org/) installed
- Proxmox VE cluster with API access
- VM template prepared with cloud-init support - Follow this guide: [Automating VM Deployment in Proxmox using OpenTofu and Cloud-Init](https://www.roksblog.de/automating-vm-deployment-in-proxmox-using-opentofu-and-cloud-init-pt-1/)
- SSH public keys for VM access

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/r0k5t4r/tf-proxmox-multi-vms.git
cd tf-proxmox-multi-vms
```

### 2. Initialize OpenTofu

```bash
tofu init --lock=false
```

> Note: The `--lock=false` flag is used because the code resides on an SMB share which doesn't handle Terraform's state locking properly. You can omit this flag if your files are on a local filesystem.

### 3. Configure Your Environment

The repository includes several pre-configured environment files in the `environments/` directory:

- `ceph.tfvars` - CEPH storage cluster  
- `openstack-allinone.tfvars` - Single-node OpenStack deployment
- `openstack-multinode-dev.tfvars` - Multi-node OpenStack development deployment
- `openstack-multnode.tfvars` - Multi-node OpenStack production deployment
- `dev.tfvars` - Development environment
- `prod.tfvars` - Production environment

#### Required Configuration Changes

Before deploying any environment, you **must** adjust the following settings in your chosen `.tfvars` file to match your Proxmox environment:

1. **Proxmox API Configuration**:
   ```hcl
   proxmox_api_url = "https://192.168.2.11:8006/api2/json"  # Change to your Proxmox IP
   proxmox_api_token_id = "root@pam!terraform"              # Your API token ID
   proxmox_api_token_secret = ""                            # Your API token secret
   ```

2. **Proxmox Node and Storage**:
   ```hcl
   proxmox_node = "pve"                 # Change to your Proxmox node name
   vm_template = "rocky-9-ci-template"  # Change to your template name
   storage = "zfs_vms"                  # Change to your storage pool name
   ```

3. **Network Configuration**:
   - Verify that the network bridges (e.g., `vmbr0`) exist in your Proxmox setup
   - Adjust IP addresses, VLANs, and gateways to match your network infrastructure

4. **VM IDs**:
   - Check that the VMIDs specified in the configuration are not already in use in your Proxmox environment
   - Adjust VMIDs as necessary to avoid conflicts

#### Optional Configuration Changes

Most other settings should work with the defaults, but you may want to adjust:
- VM specifications (CPU, memory, disk size)
- Network IP ranges and VLANs
- VM names and descriptions
- Tags for better organization

### 4. Deploy Your Environment

#### Deploy CEPH Environment

```bash
tofu plan -var-file="environments/ceph.tfvars" -state="ceph.tfstate" --lock=false
tofu apply -var-file="environments/ceph.tfvars" -state="ceph.tfstate" --lock=false
```

#### Deploy OpenStack Environment

```bash
tofu plan -var-file="environments/openstack-allinone.tfvars" -state="openstack.tfstate" --lock=false
tofu apply -var-file="environments/openstack-allinone.tfvars" -state="openstack.tfstate" --lock=false
```

#### Deploy Development Environment

```bash
tofu plan -var-file="environments/dev.tfvars" -state="dev.tfstate" --lock=false
tofu apply -var-file="environments/dev.tfvars" -state="dev.tfstate" --lock=false
```

### State Management

Each environment uses its own state file to prevent conflicts:

```bash
# Save your current setup (if migrating from existing state)
tofu state pull > backup.tfstate.backup
mv terraform.tfstate openstack.tfstate
```

### Viewing Outputs

#### See All Outputs

```bash
tofu output -state="ceph.tfstate"
```

#### See Specific Outputs

```bash
# See all VM IPs
tofu output vm_ips -state="ceph.tfstate"

# See VM details
tofu output vm_details -state="ceph.tfstate"

# See SSH commands
tofu output ssh_commands -state="ceph.tfstate"

# See additional disk info
tofu output vm_additional_disks -state="ceph.tfstate"
```

### Destroying Environments

#### Destroy CEPH Environment

```bash
tofu destroy -var-file="environments/ceph.tfvars" -state="ceph.tfstate" --lock=false
```

#### Destroy OpenStack Environment

```bash
tofu destroy -var-file="environments/openstack-allinone.tfvars" -state="openstack.tfstate" --lock=false
```

#### Destroy Development Environment

```bash
tofu destroy -var-file="environments/dev.tfvars" -state="dev.tfstate" --lock=false
```

## Configuration Examples

### Basic VM Configuration

```hcl
vms = [
  {
    name           = "prod-web-server"
    vmid           = 99200
    cores          = 2
    sockets        = 1
    memory         = 2048
    disk_size      = "10G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", ip = "192.168.2.101/24", gateway = "192.168.2.1" }
    ]
    description = "production Web Server New"
    tags        = ["web", "production"]
  }
]
```

### CEPH Storage Node with Additional Disks

```hcl
vms = [
  {
    name           = "osd01"
    vmid           = 9302
    cores          = 4
    sockets        = 1
    memory         = 8192
    disk_size      = "30G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.151/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 30, ip = "192.168.30.151/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 40, ip = "192.168.40.151/24", gateway = "192.168.40.1" }
    ]
    description      = "OSD Node 01"
    tags             = ["osd", "ceph"]
    additional_disks = [
      { storage = "zfs_vms", size = "20G", type = "scsi" },
      { storage = "zfs_vms", size = "20G", type = "scsi" }
    ]
  }
]
```

## SSH Key Management

SSH keys are managed in the `ssh_keys.txt` file. This file should contain your public keys:

```bash
cat > ssh_keys.txt << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAA... your-key-here user@hostname
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... your-ed25519-key user@hostname
EOF
```

## File Structure

```
.
├── main.tf                             # Main OpenTofu configuration
├── variables.tf                        # Variable definitions
├── outputs.tf                          # Output definitions
├── provider.tf                         # Provider configuration
├── ssh_keys.txt                        # SSH public keys
├── environments/                       # Environment configurations
│   ├── ceph.tfvars                     # CEPH environment
│   ├── openstack-allinone.tfvars       # Single-node OpenStack
│   ├── openstack-multinode-dev.tfvars  # Multi-node OpenStack dev
│   ├── openstack-multnode.tfvars       # Multi-node OpenStack prod
│   ├── dev.tfvars                      # Development environment
│   └── prod.tfvars                     # Production environment
├── *.tfstate                           # State files (created after deployment)
└── README.md                           # This file
```

## Troubleshooting

### Common Issues

- **State Locking Errors**: Use `--lock=false` flag when working with SMB shares
- **SSH Key Errors**: Ensure `ssh_keys.txt` contains valid public keys
- **Network Configuration**: Verify VLAN and bridge configurations match your Proxmox setup
- **Template Issues**: Ensure your VM template supports cloud-init
- **VMID Conflicts**: Check that VMIDs are not already in use in your Proxmox environment
- **API Token Issues**: Verify your Proxmox API token has sufficient permissions

### /etc/hosts Resets on Reboot

**Issue**:  
The `/etc/hosts` file is reset on every VM reboot.

**Cause**:  
This behavior is caused by `cloud-init`, which regenerates the file based on its configuration.

By default, this is enabled via the following setting in `/etc/cloud/cloud.cfg`:

```yaml
manage_etc_hosts: true
```

**Solution**:  
To prevent cloud-init from overwriting `/etc/hosts`, change the setting to:

```yaml
manage_etc_hosts: false
```

Then either reboot the VM or rerun cloud-init:

```bash
sudo cloud-init clean
sudo cloud-init init
```

### Reset password

**Issue**:  
You forgot the password of the default user

```bash
qm stop 99102
qm set 99102 --ciuser ubuntu --cipassword ubuntu
qm start 99102

```

## Useful Commands

```bash
# Check OpenTofu version
tofu version

# Validate configuration
tofu validate

# Format configuration files
tofu fmt

# Show current state
tofu show -state="environment.tfstate"

# List resources in state
tofu state list -state="environment.tfstate"
```

## Contributing

- Fork the repository  
- Create a feature branch  
- Make your changes  
- Test thoroughly  
- Submit a pull request  

## License

Add your license information here