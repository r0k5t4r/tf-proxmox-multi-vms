# openstack-multnode.tfvars
# OpenStack lab / environment configuration on Proxmox

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
    name        = "seed"
    vmid        = 9601
    cores       = 4
    sockets     = 1
    memory      = 8192
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.140/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.140/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.140/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.140/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.140/24",  gateway = "192.168.9.1" }
    ]

    description = "Seed Node"
    tags        = ["seed", "openstack"]
  },
  {
    name        = "control01"
    vmid        = 9602
    cores       = 4
    sockets     = 1
    memory      = 16384
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.141/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.141/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.141/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.141/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.141/24",  gateway = "192.168.9.1" },

      # Optional extra NIC (intentionally unconfigured)
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "", gateway = "" }
    ]

    description = "Control Node 01"
    tags        = ["control", "openstack"]
  },
  {
    name        = "control02"
    vmid        = 9604
    cores       = 4
    sockets     = 1
    memory      = 16384
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.142/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.142/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.142/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.142/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.142/24",  gateway = "192.168.9.1" }
    ]

    description = "Control Node 02"
    tags        = ["control", "openstack"]
  },
  {
    name        = "control03"
    vmid        = 9605
    cores       = 4
    sockets     = 1
    memory      = 16384
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.143/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.143/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.143/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.143/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.143/24",  gateway = "192.168.9.1" }
    ]

    description = "Control Node 03"
    tags        = ["control", "openstack"]
  },
  {
    name        = "compute01"
    vmid        = 9603
    cores       = 4
    sockets     = 1
    memory      = 12288
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.144/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.144/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.144/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.144/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.144/24",  gateway = "192.168.9.1" }
    ]

    description = "Compute Node 01"
    tags        = ["compute", "openstack"]
  },
  {
    name        = "compute02"
    vmid        = 9606
    cores       = 4
    sockets     = 1
    memory      = 12288
    disk_size   = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.145/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.145/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.145/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.145/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.145/24",  gateway = "192.168.9.1" }
    ]

    description = "Compute Node 02"
    tags        = ["compute", "openstack"]
  }
]
