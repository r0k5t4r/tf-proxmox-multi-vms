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

variable "default_cloud_init_name" {
  description = "Default cloud-init file if not specified per VM"
  type        = string
  default     = "default-cloud-init.yaml"
}

variable "sshpass" {
  description = "Proxmox user password for SSH to copy cloud-init file to snippets dir"
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

# VM configurations
variable "vms" {
  description = "Configuration for different VMs"
  type = list(object({
    name        = string
    vmid        = number
    cloud_init_name = optional(string)
    cores       = number
    sockets     = number
    memory      = number
    disk_size   = string
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
      name        = "web-server-1"
      vmid        = 9101
      cores       = 2
      sockets     = 1
      memory      = 2048
      disk_size   = "20G"
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
      name        = "db-server-1"
      vmid        = 9102
      cores       = 4
      sockets     = 1
      memory      = 4096
      disk_size   = "30G"
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