proxmox_api_url          = "https://192.168.2.11:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = ""
proxmox_node             = "pve"
proxmox_tls_insecure     = true
proxmox_debug            = false
vm_template              = "rocky-9-ci-template"
#vm_template             = "ubuntu-2404-ci-template"
storage                  = "zfs_vms"
ci_user                  = "rocky"
ci_password              = "rocky"

vms = [
  {
    name           = "dev-web-server"
    vmid           = 99100
    cores          = 2
    sockets        = 1
    memory         = 2048
    disk_size      = "10G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", ip = "192.168.2.101/24", gateway = "192.168.2.1" }
    ]
    description = "dev Web Server New"
    tags        = ["web", "dev"]
  },
  {
    name           = "dev-web-server2"
    vmid           = 99101
    cores          = 2
    sockets        = 1
    memory         = 2048
    disk_size      = "10G"
    network_config = [
      { model = "virtio", bridge = "vmbr0", ip = "192.168.2.102/24", gateway = "192.168.2.1" }
    ]
    description = "dev Web Server 2 New"
    tags        = ["web", "dev"]
  }
]
