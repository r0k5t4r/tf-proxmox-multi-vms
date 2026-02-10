# cloud-init.tf – generic cloud-init handling without template provider

# we can inject variables to our cloud-init file by specifying them below
locals {
  cloud_init_by_vm = {
    for vm in var.vms :
    vm.name => templatefile(
      "${path.module}/environments/${coalesce(vm.cloud_init_name, var.default_cloud_init_name)}",
      {
        ssh_key  = file("${path.module}/ssh_keys.txt")
        hostname = vm.name
      }
    )
  }
}


# Create a local copy of the rendered cloud-init file
resource "local_file" "cloud_init" {
  for_each = local.cloud_init_by_vm

  content  = each.value
  filename = "${path.module}/files/${each.key}-cloud-init.yaml"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init" {
  for_each = local.cloud_init_by_vm

  triggers = {
    checksum = sha256(each.value)
  }

  connection {
    type     = "ssh"
    user     = var.sshuser
    password = var.sshpass
    private_key = var.ssh_private_key != null ? file(var.ssh_private_key) : null
    host     = var.proxmox_node
  }

  provisioner "file" {
    source      = local_file.cloud_init[each.key].filename
    destination = "/var/lib/vz/snippets/${each.key}-cloud-init.yaml"
  }
}
