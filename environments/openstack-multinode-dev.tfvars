# openstack-multinode-dev.tfvars
# Development OpenStack environment on Proxmox
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
    name      = "seed-dev"
    vmid      = 9201
    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.150/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.150/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.150/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.150/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.150/24",  gateway = "192.168.9.1" }
    ]

    description = "Seed Node (Dev)"
    tags        = ["seed", "openstack-dev"]
  },
  {
    name      = "control01-dev"
    vmid      = 9202
    cores     = 4
    sockets   = 1
    memory    = 16384
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.151/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.151/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.151/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.151/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.151/24",  gateway = "192.168.9.1" },

      # Optional extra NIC (intentionally unconfigured, e.g. Neutron/SR-IOV)
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "", gateway = "" }
    ]

    description = "Control Node 01 (Dev)"
    tags        = ["control", "openstack-dev"]
  },
  {
    name      = "control02-dev"
    vmid      = 9204
    cores     = 4
    sockets   = 1
    memory    = 16384
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.152/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.152/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.152/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.152/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.152/24",  gateway = "192.168.9.1" }
    ]

    description = "Control Node 02 (Dev)"
    tags        = ["control", "openstack-dev"]
  },
  {
    name      = "control03-dev"
    vmid      = 9205
    cores     = 4
    sockets   = 1
    memory    = 16384
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.153/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.153/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.153/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.153/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.153/24",  gateway = "192.168.9.1" }
    ]

    description = "Control Node 03 (Dev)"
    tags        = ["control", "openstack-dev"]
  },
  {
    name      = "compute01-dev"
    vmid      = 9203
    cores     = 4
    sockets   = 1
    memory    = 12288
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.154/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.154/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.154/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.154/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.154/24",  gateway = "192.168.9.1" }
    ]

    description = "Compute Node 01 (Dev)"
    tags        = ["compute", "openstack-dev"]
  },
  {
    name      = "compute02-dev"
    vmid      = 9206
    cores     = 4
    sockets   = 1
    memory    = 12288
    disk_size = "100G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.155/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 20, ip = "192.168.20.155/24", gateway = "192.168.20.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 43, ip = "192.168.43.155/24", gateway = "192.168.43.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.50.155/24", gateway = "192.168.50.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.9.155/24",  gateway = "192.168.9.1" }
    ]

    description = "Compute Node 02 (Dev)"
    tags        = ["compute", "openstack-dev"]
  }
]
