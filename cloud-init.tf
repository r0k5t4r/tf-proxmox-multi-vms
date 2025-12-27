# cloud-init.tf – cloud-init configuration without template provider

# we can inject variables to our cloud-init file by specifying them below
locals {
  cloud_init_test1 = templatefile(
    "${path.module}/environments/docker-cloud-init.yaml",
    {
      ssh_key = file("${path.module}/ssh_keys.txt")
      #hostname = var.vmname
      #domain   = var.domain
    }
  )
}

# Create a local copy of the rendered cloud-init file
resource "local_file" "cloud_init_test1" {
  content  = local.cloud_init_test1
  filename = "${path.module}/files/vendor_data_cloud_init_test1.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_test1" {
  connection {
    type     = "ssh"
    user     = var.sshuser
    password = var.sshpass
    # private_key = file("~/.ssh/id_ed25519")
    host     = var.proxmox_node
  }

  provisioner "file" {
    source      = local_file.cloud_init_test1.filename
    destination = "/var/lib/vz/snippets/docker-cloud-init.yaml"
  }
}
