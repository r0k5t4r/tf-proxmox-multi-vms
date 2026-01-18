# prod.tfvars
# Production environment configuration for Proxmox

proxmox_api_url          = "https://192.168.2.11:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = ""
proxmox_node             = "pve"
proxmox_tls_insecure     = true
proxmox_debug            = false

# SSH access to Proxmox host (for snippet upload)
sshuser = "root"
sshpass = ""

# VM template
vm_template = "rocky-9-ci-template"
# vm_template = "ubuntu-2404-ci-template"

# Storage
storage = "zfs_vms"

# Cloud-init defaults
ci_user     = "rocky"
ci_password = "rocky"
ci_upgrade  = false

# Optional: override the default cloud-init for all production VMs
# default_cloud_init_name = "prod-cloud-init.yaml"

vms = [
  {
    name       = "prod-web-server"
    vmid       = 99200
    cores      = 2
    sockets    = 1
    memory     = 2048
    disk_size = "10G"

    network_config = [
      {
        model   = "virtio"
        bridge  = "vmbr0"
        ip      = "192.168.2.101/24"
        gateway = "192.168.2.1"
      }
    ]

    description = "Production Web Server 1"
    tags        = ["web", "production"]
  },
  {
    name       = "prod-web-server2"
    vmid       = 99201
    cores      = 2
    sockets    = 1
    memory     = 2048
    disk_size = "10G"

    network_config = [
      {
        model   = "virtio"
        bridge  = "vmbr0"
        ip      = "192.168.2.102/24"
        gateway = "192.168.2.1"
      }
    ]

    description = "Production Web Server 2"
    tags        = ["web", "production"]
  }
]
