# docker.tfvars
# Environment configuration for a Docker test VM on Proxmox

proxmox_api_url          = "https://192.168.2.11:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = ""
proxmox_node             = "pve"
proxmox_tls_insecure     = true
proxmox_debug            = true

# SSH access to Proxmox host (for snippet upload)
sshuser = "root"
sshpass = ""

# VM template
vm_template = "ubuntu-2404-ci-template"
# vm_template = "rocky-9-ci-template"

# Storage
storage = "zfs_vms"

# Cloud-init defaults
ci_user     = "ubuntu"
ci_password = "ubuntu"
ci_upgrade  = false

vms = [
  {
    name            = "cicustom"
    vmid            = 99102
    cloud_init_name = "docker-cloud-init.yaml"

    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "60G"

    network_config = [
      {
        model   = "virtio"
        bridge  = "vmbr0"
        ip      = "192.168.2.120/24"
        gateway = "192.168.2.1"
      }
    ]

    description = "Cloud-init Docker Test VM"
    tags        = ["cloud-init", "docker", "dev"]
  }
]
