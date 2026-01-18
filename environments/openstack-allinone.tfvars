# openstack-allinone.tfvars
# Single seed node configuration for OpenStack on Proxmox

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

vms = [
  {
    name      = "seed"
    vmid      = 9101
    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.140/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.140/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.140/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.140/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.140/24",  gateway = "192.168.9.1" }
    ]

    description = "Seed Node"
    tags        = ["seed", "openstack"]
  }
]
