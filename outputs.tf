# Output the VM IPs from configuration
output "vm_ips" {
  value = {
    for vm in var.vms : vm.name => {
      all_ips = [for net in vm.network_config : net.ip]
    }
  }
  description = "List of all IPs for each VM from configuration"
}

# Output actual VM information after deployment
output "vm_details" {
  value = {
    for vm in proxmox_vm_qemu.vms : vm.name => {
      vmid = vm.vmid
      cores = vm.cores
      memory = vm.memory
      actual_ip = vm.default_ipv4_address
      ssh_host = vm.ssh_host
      tags = vm.tags
      vm_state = vm.vm_state
    }
  }
  description = "Detailed information about deployed VMs"
}

# Output SSH connection commands
output "ssh_commands" {
  value = {
    for vm in proxmox_vm_qemu.vms : vm.name => "ssh rocky@${vm.default_ipv4_address}"
  }
  description = "SSH commands to connect to each VM"
}

# Output additional disk information
output "vm_additional_disks" {
  value = {
    for i, vm in var.vms : vm.name => {
      disk_count = length(vm.additional_disks)
      total_additional_storage = length(vm.additional_disks) > 0 ? "${sum([for disk in vm.additional_disks : tonumber(replace(disk.size, "G", ""))])}G" : "0G"
      disk_details = length(vm.additional_disks) > 0 ? [
        for disk in vm.additional_disks : {
          size = disk.size
          type = lookup(disk, "type", "scsi")
          storage = disk.storage
        }
      ] : []
    }
  }
  description = "Additional disk information for each VM"
}
