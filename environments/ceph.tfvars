# ceph.tfvars
# Environment configuration for a Ceph lab on Proxmox
# Proxmox API credentials are defined in terraform.tfvars

# VM template used for all nodes
vm_template = "rocky-9-ci-template"
# vm_template = "ubuntu-2404-ci-template"

# Cloud-init defaults
ci_user     = "rocky"
ci_password = "rocky"
ci_upgrade  = false

# Optional: override the default cloud-init for all VMs
# default_cloud_init_name = "cephadm-osd.yaml"

vms = [
  {
    name            = "bootstrap"
    vmid            = 9301
    cloud_init_name = "cephadm-cloud-init.yaml"

    cores    = 4
    sockets  = 1
    memory   = 8192
    disk_size = "30G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.150/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.30.150/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 9,  ip = "192.168.40.150/24", gateway = "192.168.40.1" }
    ]

    description      = "Bootstrap Node"
    tags             = ["bootstrap", "ceph"]
    additional_disks = []
  },
  {
    name       = "osd01"
    vmid       = 9302
    cores      = 4
    sockets    = 1
    memory     = 8192
    disk_size = "30G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.151/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 30, ip = "192.168.30.151/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 40, ip = "192.168.40.151/24", gateway = "192.168.40.1" }
    ]

    description = "OSD Node 01"
    tags        = ["osd", "ceph"]
    additional_disks = [
      { storage = "zfs_vms", size = "20G", type = "scsi" },
      { storage = "zfs_vms", size = "20G", type = "scsi" }
    ]
  },
  {
    name       = "osd02"
    vmid       = 9303
    cores      = 4
    sockets    = 1
    memory     = 8192
    disk_size = "30G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.152/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 30, ip = "192.168.30.152/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 40, ip = "192.168.40.152/24", gateway = "192.168.40.1" }
    ]

    description = "OSD Node 02"
    tags        = ["osd", "ceph"]
    additional_disks = [
      { storage = "zfs_vms", size = "20G", type = "scsi" },
      { storage = "zfs_vms", size = "20G", type = "scsi" }
    ]
  },
  {
    name       = "osd03"
    vmid       = 9304
    cores      = 4
    sockets    = 1
    memory     = 8192
    disk_size = "30G"

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.153/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 30, ip = "192.168.30.153/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 40, ip = "192.168.40.153/24", gateway = "192.168.40.1" }
    ]

    description = "OSD Node 03"
    tags        = ["osd", "ceph"]
    additional_disks = [
      { storage = "zfs_vms", size = "20G", type = "scsi" },
      { storage = "zfs_vms", size = "20G", type = "scsi" },
      { storage = "zfs_vms", size = "20G", type = "scsi" }
    ]
  }
]
