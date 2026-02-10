# prod.tfvars
# Production environment configuration
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
