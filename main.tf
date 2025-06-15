# Provider configuration
terraform {
  required_version = ">= 0.13"
    required_providers {
        proxmox = {
        source = "telmate/proxmox"
        version = "3.0.1-rc8"
        }
    }
}

# Resource to create multiple VMs
resource "proxmox_vm_qemu" "vms" {
  count = length(var.vms)
  
  name = var.vms[count.index].name
  vmid = var.vms[count.index].vmid
  target_node = var.proxmox_node
  
  clone = var.vm_template
  
  # VM Resources
  cores = var.vms[count.index].cores
  sockets = var.vms[count.index].sockets
  memory = var.vms[count.index].memory
  bootdisk = "virtio0"
  scsihw = "virtio-scsi-pci"
  
  # Disks
  disks {
    # Cloud-init drive
    scsi {
      scsi1 {
        cloudinit {
          storage = "zfs_vms"
        }
      }
      
      # Additional SCSI disks - Fixed with proper filtering
      dynamic "scsi2" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 0 && lookup(disk, "type", "scsi") == "scsi"
        ]
        content {
          disk {
            size    = scsi2.value.size
            cache   = lookup(scsi2.value, "cache", "none")
            storage = scsi2.value.storage
          }
        }
      }
      
      dynamic "scsi3" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 1 && lookup(disk, "type", "scsi") == "scsi"
        ]
        content {
          disk {
            size    = scsi3.value.size
            cache   = lookup(scsi3.value, "cache", "none")
            storage = scsi3.value.storage
          }
        }
      }
      
      dynamic "scsi4" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 2 && lookup(disk, "type", "scsi") == "scsi"
        ]
        content {
          disk {
            size    = scsi4.value.size
            cache   = lookup(scsi4.value, "cache", "none")
            storage = scsi4.value.storage
          }
        }
      }
    }   
    
    # Boot disk and additional virtio disks
    virtio {
      virtio0 {
        disk {
          size            = 40
          cache           = "writeback"
          storage         = "zfs_vms"
        }
      }
      
      # Additional virtio disks - Fixed with proper filtering
      dynamic "virtio1" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 0 && lookup(disk, "type", "scsi") == "virtio"
        ]
        content {
          disk {
            size    = virtio1.value.size
            cache   = lookup(virtio1.value, "cache", "writeback")
            storage = virtio1.value.storage
          }
        }
      }
      
      dynamic "virtio2" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 1 && lookup(disk, "type", "scsi") == "virtio"
        ]
        content {
          disk {
            size    = virtio2.value.size
            cache   = lookup(virtio2.value, "cache", "writeback")
            storage = virtio2.value.storage
          }
        }
      }
      
      dynamic "virtio3" {
        for_each = [
          for idx, disk in var.vms[count.index].additional_disks : disk 
          if idx == 2 && lookup(disk, "type", "scsi") == "virtio"
        ]
        content {
          disk {
            size    = virtio3.value.size
            cache   = lookup(virtio3.value, "cache", "writeback")
            storage = virtio3.value.storage
          }
        }
      }
    }
  }

  # Network configuration
  dynamic "network" {
    for_each = slice(var.vms[count.index].network_config, 0, min(5, length(var.vms[count.index].network_config)))
    content {
      id = network.key
      model = network.value.model
      bridge = network.value.bridge
      tag = lookup(network.value, "vlan", null)
    }
  }

  # Cloud-init settings
  os_type = "cloud-init"
  
  # Handle network configurations more explicitly
  ipconfig0 = length(var.vms[count.index].network_config) > 0 ? "ip=${var.vms[count.index].network_config[0].ip},gw=${var.vms[count.index].network_config[0].gateway}" : ""
  ipconfig1 = length(var.vms[count.index].network_config) > 1 ? "ip=${var.vms[count.index].network_config[1].ip},gw=${var.vms[count.index].network_config[1].gateway}" : ""
  ipconfig2 = length(var.vms[count.index].network_config) > 2 ? "ip=${var.vms[count.index].network_config[2].ip},gw=${var.vms[count.index].network_config[2].gateway}" : ""
  ipconfig3 = length(var.vms[count.index].network_config) > 3 ? "ip=${var.vms[count.index].network_config[3].ip},gw=${var.vms[count.index].network_config[3].gateway}" : ""
  ipconfig4 = length(var.vms[count.index].network_config) > 4 ? "ip=${var.vms[count.index].network_config[4].ip},gw=${var.vms[count.index].network_config[4].gateway}" : ""
  ipconfig5 = "manual"

  # Cloud-Init Configuration
  ciuser      = "rocky"
  cipassword  = "rocky"
  sshkeys     = file("${path.module}/ssh_keys.txt")  # Temporarily disabled
  ciupgrade = true

  # Additional VM settings
  tags = join(";", var.vms[count.index].tags)
  
  # Agent configuration
  agent = 1
  full_clone = false
  onboot = true

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
