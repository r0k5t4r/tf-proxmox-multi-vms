# Proxmox connection variables
variable "proxmox_api_url" {
  description = "The URL of the Proxmox API"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "The API token ID for Proxmox authentication"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "The API token secret for Proxmox authentication"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "The name of the Proxmox node"
  type        = string
  default     = "pve"
}

variable "proxmox_tls_insecure" {
  description = "Turn off TLS verification"
  type        = bool
  default     = true
}

variable "proxmox_debug" {
  description = "Enable debug logging"
  type        = bool
  default     = false
}

variable "sshuser" {
  description = "Proxmox user for SSH to copy cloud-init file to snippets dir"
  type        = string
  default     = "root"
}

variable "snippet_storage_id" {
  description = "Proxmox storage ID that provides the snippets content (used in cicustom vendor=...:snippets/...)"
  type        = string
  default     = "dir01"
}

variable "snippet_upload_dir" {
  description = "Absolute path on the Proxmox node where snippet files must be uploaded via SSH"
  type        = string
  default     = "/mnt/pve/dir01/snippets"
}

variable "ssh_host" {
  description = "Host used for the SSH snippet upload (defaults to proxmox_node name; set to the node IP if the node name is not resolvable)"
  type        = string
  default     = null
}

variable "default_cloud_init_name" {
  description = "Default cloud-init file if not specified per VM"
  type        = string
  default     = "default-cloud-init.yaml"
}

variable "sshpass" {
  description = "Proxmox user password for SSH to copy cloud-init file to snippets dir (optional if using ssh_private_key)"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Path to private SSH key for Proxmox authentication (optional if using sshpass)"
  type        = string
  default     = null
}

# VM template and storage variables
variable "vm_template" {
  description = "The template to clone for creating VMs"
  type        = string
}

variable "storage" {
  description = "The storage pool to use for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "ceph_cluster_network" {
  description = "Cluster network CIDR used by cephadm bootstrap"
  type        = string
  default     = "192.168.30.0/24"
}

variable "ceph_public_networks" {
  description = "Public Ceph client networks exposed by monitors and gateways"
  type        = list(string)
  default     = ["192.168.2.0/24"]
}

variable "ceph_mon_network_index" {
  description = "Index of the bootstrap VM network_config entry used for the Ceph monitor/public IP"
  type        = number
  default     = 0
}

# Cloud-init user configuration
variable "ci_user" {
  description = "Cloud-init default user"
  type        = string
  default     = "rocky"
}

variable "ci_password" {
  description = "Cloud-init default password"
  type        = string
  default     = "rocky"
  sensitive   = true
}

variable "ci_upgrade" {
  description = "Cloud-init update all packages on first boot"
  type        = bool
  default     = false
}

variable "cicustom_vendor" {
  description = "Optional additional cloud-init vendor-data YAML"
  type        = string
  default     = ""
}

variable "domain" {
  description = "Optional domain name for VMs"
  type        = string
  default     = ""
}

variable "proxy_url" {
  type    = string
  default = ""
}

variable "no_proxy" {
  type    = string
  default = "localhost,127.0.0.1,.tpzdrestricted.corp"
}

variable "katello_register_url" {
  type    = string
  default = ""
}

variable "enforce_disable_system_repos" {
  type    = string
  default = "1"
}

# ---------------------------------------------------------------------------
# Katello content (products & repositories), created post-install by
# templates/katello-repos.sh.tmpl via the katello cloud-init environment.
# All repos use download-on-demand so content is only pulled when a
# registered host actually requests it.
# ---------------------------------------------------------------------------

variable "katello_gpg_keys" {
  description = "Content credentials (GPG keys) to create in Katello"
  type = list(object({
    name = string
    url  = string
  }))
  default = [
    { name = "ATIX GPG key", url = "https://oss.atix.de/atix_gpg.pub" },
    { name = "Rocky 8 GPG key", url = "https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-8" },
    { name = "Rocky 9 GPG key", url = "https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9" },
    { name = "Rocky 10 GPG key", url = "https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-10" },
  ]
}

variable "katello_yum_repos" {
  description = "RPM (yum) repositories created in Katello; download-policy on_demand"
  type = list(object({
    product         = string
    name            = string
    url             = string
    gpg_key         = optional(string, "")
    download_policy = optional(string, "on_demand")
  }))
  default = [
    # --- Rocky Linux 8 (CRB is called PowerTools here) ---
    { product = "Rocky Linux 8", name = "BaseOS", url = "https://dl.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/", gpg_key = "Rocky 8 GPG key" },
    { product = "Rocky Linux 8", name = "AppStream", url = "https://dl.rockylinux.org/pub/rocky/8/AppStream/x86_64/os/", gpg_key = "Rocky 8 GPG key" },
    { product = "Rocky Linux 8", name = "PowerTools", url = "https://dl.rockylinux.org/pub/rocky/8/PowerTools/x86_64/os/", gpg_key = "Rocky 8 GPG key" },
    { product = "Rocky Linux 8", name = "Extras", url = "https://dl.rockylinux.org/pub/rocky/8/extras/x86_64/os/", gpg_key = "Rocky 8 GPG key" },
    # --- Rocky Linux 9 ---
    { product = "Rocky Linux 9", name = "BaseOS", url = "https://dl.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/", gpg_key = "Rocky 9 GPG key" },
    { product = "Rocky Linux 9", name = "AppStream", url = "https://dl.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/", gpg_key = "Rocky 9 GPG key" },
    { product = "Rocky Linux 9", name = "CRB", url = "https://dl.rockylinux.org/pub/rocky/9/CRB/x86_64/os/", gpg_key = "Rocky 9 GPG key" },
    { product = "Rocky Linux 9", name = "Extras", url = "https://dl.rockylinux.org/pub/rocky/9/extras/x86_64/os/", gpg_key = "Rocky 9 GPG key" },
    # --- Rocky Linux 10 ---
    { product = "Rocky Linux 10", name = "BaseOS", url = "https://dl.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/", gpg_key = "Rocky 10 GPG key" },
    { product = "Rocky Linux 10", name = "AppStream", url = "https://dl.rockylinux.org/pub/rocky/10/AppStream/x86_64/os/", gpg_key = "Rocky 10 GPG key" },
    { product = "Rocky Linux 10", name = "CRB", url = "https://dl.rockylinux.org/pub/rocky/10/CRB/x86_64/os/", gpg_key = "Rocky 10 GPG key" },
    { product = "Rocky Linux 10", name = "Extras", url = "https://dl.rockylinux.org/pub/rocky/10/extras/x86_64/os/", gpg_key = "Rocky 10 GPG key" },
  ]
}

variable "katello_deb_repos" {
  description = "Debian/Ubuntu (deb) base/update/security repositories created in Katello"
  type = list(object({
    product         = string
    name            = string
    url             = string
    releases        = string # deb suite(s), whitespace separated
    components      = string # deb components, whitespace separated
    architectures   = optional(string, "amd64")
    gpg_key         = optional(string, "")
    download_policy = optional(string, "on_demand")
  }))
  default = [
    # --- Ubuntu 20.04 (focal, EOL Standard Support 2025 - base repos remain available) ---
    { product = "Ubuntu 20.04", name = "Base", url = "https://archive.ubuntu.com/ubuntu", releases = "focal", components = "main restricted universe multiverse" },
    { product = "Ubuntu 20.04", name = "Updates", url = "https://archive.ubuntu.com/ubuntu", releases = "focal-updates", components = "main restricted universe multiverse" },
    { product = "Ubuntu 20.04", name = "Security", url = "https://security.ubuntu.com/ubuntu", releases = "focal-security", components = "main restricted universe multiverse" },
    # --- Ubuntu 22.04 (jammy) ---
    { product = "Ubuntu 22.04", name = "Base", url = "https://archive.ubuntu.com/ubuntu", releases = "jammy", components = "main restricted universe multiverse" },
    { product = "Ubuntu 22.04", name = "Updates", url = "https://archive.ubuntu.com/ubuntu", releases = "jammy-updates", components = "main restricted universe multiverse" },
    { product = "Ubuntu 22.04", name = "Security", url = "https://security.ubuntu.com/ubuntu", releases = "jammy-security", components = "main restricted universe multiverse" },
    # --- Ubuntu 24.04 (noble) ---
    { product = "Ubuntu 24.04", name = "Base", url = "https://archive.ubuntu.com/ubuntu", releases = "noble", components = "main restricted universe multiverse" },
    { product = "Ubuntu 24.04", name = "Updates", url = "https://archive.ubuntu.com/ubuntu", releases = "noble-updates", components = "main restricted universe multiverse" },
    { product = "Ubuntu 24.04", name = "Security", url = "https://security.ubuntu.com/ubuntu", releases = "noble-security", components = "main restricted universe multiverse" },
    # --- Ubuntu 26.04 (resolute) ---
    { product = "Ubuntu 26.04", name = "Base", url = "https://archive.ubuntu.com/ubuntu", releases = "resolute", components = "main restricted universe multiverse" },
    { product = "Ubuntu 26.04", name = "Updates", url = "https://archive.ubuntu.com/ubuntu", releases = "resolute-updates", components = "main restricted universe multiverse" },
    { product = "Ubuntu 26.04", name = "Security", url = "https://security.ubuntu.com/ubuntu", releases = "resolute-security", components = "main restricted universe multiverse" },
  ]
}

variable "katello_subscription_manager_deb_repos" {
  description = "Separate product holding the ATIX subscription-manager repos (one per supported Ubuntu release); hosts need this for Katello registration"
  type = list(object({
    product         = string
    name            = string
    url             = string
    releases        = string
    components      = string
    architectures   = optional(string, "amd64")
    gpg_key         = optional(string, "")
    download_policy = optional(string, "on_demand")
  }))
  default = [
    { product = "ATIX Subscription Manager", name = "Ubuntu 20.04", url = "https://oss.atix.de/Ubuntu20LTS/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
    { product = "ATIX Subscription Manager", name = "Ubuntu 22.04", url = "https://oss.atix.de/Ubuntu22LTS/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
    { product = "ATIX Subscription Manager", name = "Ubuntu 24.04", url = "https://oss.atix.de/Ubuntu24LTS/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
    { product = "ATIX Subscription Manager", name = "Ubuntu 26.04", url = "https://oss.atix.de/Ubuntu26LTS/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
    { product = "ATIX Subscription Manager", name = "Debian 12", url = "https://oss.atix.de/Debian12/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
    { product = "ATIX Subscription Manager", name = "Debian 13", url = "https://oss.atix.de/Debian13/", releases = "stable", components = "main", gpg_key = "ATIX GPG key" },
  ]
}

variable "katello_content_automation" {
  description = "Create the Katello products/repositories/content-views/activation-keys baked into the katello environment (runs post install via templates/katello-repos.sh.tmpl)"
  type        = bool
  default     = true
}

variable "katello_activation_keys" {
  description = "Configure rolling content views (one per product) and activation keys (AK <product>) referencing them"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Foreman <-> Proxmox compute resource integration (optional).
# Registers the Proxmox node in Foreman via foreman_fog_proxmox. The default
# user root@pam!terraform expects an existing PVE API token; pass its UUID in
# foreman_proxmox_password.
# ---------------------------------------------------------------------------

variable "katello_debian_repos" {
  description = "Debian (deb) base/update/security repositories created in Katello (Debian 12 bookworm, Debian 13 trixie)"
  type = list(object({
    product         = string
    name            = string
    url             = string
    releases        = string
    components      = string
    architectures   = optional(string, "amd64")
    gpg_key         = optional(string, "")
    download_policy = optional(string, "on_demand")
  }))
  default = [
    # --- Debian 12 (bookworm) ---
    { product = "Debian 12", name = "Base", url = "https://deb.debian.org/debian", releases = "bookworm", components = "main contrib non-free non-free-firmware" },
    { product = "Debian 12", name = "Updates", url = "https://deb.debian.org/debian", releases = "bookworm-updates", components = "main contrib non-free non-free-firmware" },
    { product = "Debian 12", name = "Security", url = "https://security.debian.org/debian-security", releases = "bookworm-security", components = "main contrib non-free non-free-firmware" },
    # --- Debian 13 (trixie) ---
    { product = "Debian 13", name = "Base", url = "https://deb.debian.org/debian", releases = "trixie", components = "main contrib non-free non-free-firmware" },
    { product = "Debian 13", name = "Updates", url = "https://deb.debian.org/debian", releases = "trixie-updates", components = "main contrib non-free non-free-firmware" },
    { product = "Debian 13", name = "Security", url = "https://security.debian.org/debian-security", releases = "trixie-security", components = "main contrib non-free non-free-firmware" },
  ]
}

variable "foreman_proxmox_integration" {
  description = "Register the Proxmox node as a compute resource in Foreman (katello environment only)"
  type        = bool
  default     = false
}

variable "foreman_proxmox_name" {
  description = "Name of the compute resource in Foreman"
  type        = string
  default     = "Proxmox (pve)"
}

variable "foreman_proxmox_server" {
  description = "Proxmox VE API endpoint (must include /api2/json - fog-proxmox expects it)"
  type        = string
  default     = "https://192.168.2.11:8006/api2/json"
}

variable "foreman_proxmox_user" {
  description = "Proxmox API user like root@pam (AuthToken/MFA not included); for token auth append foreman_proxmox_token_id"
  type        = string
  default     = "root@pam"
}

variable "foreman_proxmox_auth_method" {
  description = "Proxmox auth foreman_fog_proxmox uses: 'user_token' (API token, needs foreman_proxmox_token_id) or 'access_ticket' (user+password)"
  type        = string
  default     = "user_token"
}

variable "foreman_proxmox_token_id" {
  description = "API token ID when foreman_proxmox_auth_method = user_token (e.g. 'terraform' for root@pam!terraform)"
  type        = string
  default     = "terraform"
}

variable "foreman_proxmox_password" {
  description = "Proxmox password (access_ticket) or API token UUID (user_token), secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "foreman_compute_profiles" {
  description = "Create per-OS compute profiles on the Proxmox compute resource (only when foreman_proxmox_integration is enabled)"
  type        = bool
  default     = true
}

variable "foreman_registration_setup" {
  description = "Setup the global registration: custom subscription_manager_setup snippet (ATIX SM for Debian/Ubuntu family), Global Registration (custom) template and the foreman_url setting"
  type        = bool
  default     = true
}

variable "foreman_public_url" {
  description = "Public URL of the Foreman instance used in the /etc/foreman/settings.yaml foreman_url setting (matters for generated registration commands)"
  type        = string
  default     = "https://katello.fritz.box"
}

variable "katello_registration_token_hours" {
  description = "JWT expiration in hours for generated global registration commands; 0 means unlimited"
  type        = number
  default     = 0
}

variable "foreman_compute_profile_list" {
  description = "Compute profiles to create: name, cores, memory (MB), disk size (GB) on zfs_vms with a virtio net0 interface on vmbr0"
  type = list(object({
    name   = string
    cores  = number
    memory = number
    size   = number
  }))
  default = [
    { name = "Katello - Ubuntu 20.04", cores = 2, memory = 2048, size = 20 },
    { name = "Katello - Ubuntu 22.04", cores = 2, memory = 4096, size = 20 },
    { name = "Katello - Ubuntu 24.04", cores = 2, memory = 4096, size = 20 },
    { name = "Katello - Ubuntu 26.04", cores = 4, memory = 8192, size = 40 },
    { name = "Katello - Debian 12", cores = 2, memory = 4096, size = 20 },
    { name = "Katello - Debian 13", cores = 4, memory = 8192, size = 40 },
    { name = "Katello - Rocky 8", cores = 4, memory = 8192, size = 40 },
    { name = "Katello - Rocky 9", cores = 4, memory = 8192, size = 40 },
    { name = "Katello - Rocky 10", cores = 4, memory = 8192, size = 40 },
  ]
}

# VM configurations
variable "vms" {
  description = "Configuration for different VMs"
  type = list(object({
    name            = string
    vmid            = number
    cloud_init_name = optional(string)
    cores           = number
    sockets         = number
    memory          = number
    disk_size       = string
    network_config = list(object({
      model   = string
      bridge  = string
      vlan    = optional(number, 0)
      ip      = string
      gateway = string
    }))
    description = string
    tags        = list(string)
    additional_disks = optional(list(object({
      storage = string
      size    = string
      cache   = optional(string, "none")
      type    = optional(string, "scsi") # scsi, virtio, ide, sata
    })), [])
  }))
  default = [
    {
      name      = "web-server-1"
      vmid      = 9101
      cores     = 2
      sockets   = 1
      memory    = 2048
      disk_size = "20G"
      network_config = [
        {
          model   = "virtio"
          bridge  = "vmbr0"
          ip      = "192.168.2.101/24"
          gateway = "192.168.2.1"
        }
      ]
      description      = "Web Server 1"
      tags             = ["web", "production"]
      additional_disks = []
    },
    {
      name      = "db-server-1"
      vmid      = 9102
      cores     = 4
      sockets   = 1
      memory    = 4096
      disk_size = "30G"
      network_config = [
        {
          model   = "virtio"
          bridge  = "vmbr0"
          ip      = "192.168.2.102/24"
          gateway = "192.168.2.1"
        },
        {
          model   = "virtio"
          bridge  = "vmbr0"
          ip      = "10.0.0.102/24"
          gateway = "10.0.0.1"
        }
      ]
      description      = "Database Server 1"
      tags             = ["db", "production"]
      additional_disks = []
    }
  ]
}

# OmniOS VMs (cloned from the omnios-r151058-template created by tf-creator-omnios)
variable "omnios_template" {
  description = "Clone source for OmniOS VMs (template name or VMID as string)"
  default     = "omnios-r151058-template"
}

variable "omnios_nameserver" {
  description = "DNS server written to /etc/resolv.conf in OmniOS VMs (cloud-init network is disabled on illumos)"
  default     = ""
}

variable "omnios_vms" {
  description = "OmniOS VM configuration — same shape as vms. NOTE: ip in network_config[0] can be 'dhcp' (native illumos DHCP) or a static CIDR. Static/gw changes are applied via persistent ipadm/route. disk_size must exceed the template disk (20G) when full_clone = false."
  type = list(object({
    name            = string
    vmid            = number
    cloud_init_name = optional(string)
    cores           = number
    sockets         = number
    memory          = number
    disk_size       = string
    network_config = list(object({
      model   = string
      bridge  = string
      vlan    = optional(number, 0)
      ip      = string
      gateway = string
    }))
    description = string
    tags        = list(string)
    additional_disks = optional(list(object({
      storage = string
      size    = string
      cache   = optional(string, "none")
      type    = optional(string, "scsi") # scsi, virtio, ide, sata
    })), [])
  }))
  default = []
}
