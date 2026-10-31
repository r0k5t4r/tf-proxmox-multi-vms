vm_template              = "rocky-9-ci-template"
#vm_template             = "ubuntu-2404-ci-template"
ci_user                  = "rocky"
ci_password              = "rocky"

# boot disks + cloudinit drive storage (main.tf reads var.storage)
storage                  = "zfs_vms"

vms = [
  {
    name           = "bootstrap"
    vmid           = 9301
    force_create  = true
    cores          = 4
    sockets        = 1
    memory         = 8192
    disk_size      = "45G"
    cloud_init_name = "cephadm-cloud-init.yaml"
    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.150/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.30.150/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.40.150/24", gateway = "192.168.40.1" }
    ]
    description      = "Bootstrap Node"
    tags             = ["bootstrap", "ceph"]
    additional_disks = []
  },
  {
    name           = "osd01"
    vmid           = 9302
    force_create  = true
    cores          = 4
    sockets        = 1
    memory         = 8192
    disk_size      = "45G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.151/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.30.151/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.40.151/24", gateway = "192.168.40.1" }
    ]
    description      = "OSD Node 01"
    tags             = ["osd", "ceph"]
    additional_disks = [
      { storage = "local-lvm", size = "20G", type = "scsi" },
      { storage = "local-lvm", size = "20G", type = "scsi" }
    ]
  },
  {
    name           = "osd02"
    vmid           = 9303
    force_create  = true
    cores          = 4
    sockets        = 1
    memory         = 8192
    disk_size      = "45G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.152/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.30.152/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.40.152/24", gateway = "192.168.40.1" }
    ]
    description      = "OSD Node 02"
    tags             = ["osd", "ceph"]
    additional_disks = [
      { storage = "local-lvm", size = "20G", type = "scsi" },
      { storage = "local-lvm", size = "20G", type = "scsi" }
    ]
  },
  {
    name           = "osd03"
    vmid           = 9304
    force_create  = true
    cores          = 4
    sockets        = 1
    memory         = 8192
    disk_size      = "45G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0,  ip = "192.168.2.153/24",  gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.30.153/24", gateway = "192.168.30.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.40.153/24", gateway = "192.168.40.1" }
    ]
    description      = "OSD Node 03"
    tags             = ["osd", "ceph"]
    additional_disks = [
      { storage = "local-lvm", size = "20G", type = "scsi" },
      { storage = "local-lvm", size = "20G", type = "scsi" },
      { storage = "local-lvm", size = "20G", type = "scsi" }
    ]
  }
]

