# dev.tfvars
# Development environment – simple web server VMs
# Proxmox API credentials are defined in terraform.tfvars

# VM template
vm_template = "rocky-9-ci-template"
# vm_template = "ubuntu-2404-ci-template"

# Storage
storage = "zfs_vms"

# Cloud-init defaults
ci_user     = "rocky"
ci_password = "rocky"
ci_upgrade  = false

vms = [
  {
    name      = "dev-web-server"
    vmid      = 99100
    cores     = 2
    sockets   = 1
    memory    = 2048
    disk_size = "10G"

    network_config = [
      {
        model   = "virtio"
        bridge  = "vmbr0"
        ip      = "192.168.2.101/24"
        gateway = "192.168.2.1"
      }
    ]

    description = "Development Web Server 1"
    tags        = ["web", "dev"]
  },
  {
    name      = "dev-web-server2"
    vmid      = 99101
    cores     = 2
    sockets   = 1
    memory    = 2048
    disk_size = "10G"

    network_config = [
      {
        model   = "virtio"
        bridge  = "vmbr0"
        ip      = "192.168.2.102/24"
        gateway = "192.168.2.1"
      }
    ]

    description = "Development Web Server 2"
    tags        = ["web", "dev"]
  }
]
