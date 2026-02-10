# docker.tfvars
# Environment configuration for a Docker test VM on Proxmox
# Proxmox API credentials are defined in terraform.tfvars

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
