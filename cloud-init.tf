# cloud-init.tf – generic cloud-init handling without template provider

# we can inject variables to our cloud-init file by specifying them below
# and then referencing them in the cloud-init template file using ${var.variable_name}
# for example, we can inject the hostname and domain to the cloud-init file and then use them in the template to set the hostname and domain of the VM
locals {

  ceph_nodes = [
    for vm in var.vms :
    {
      name = vm.name
      ip   = split("/", vm.network_config[var.ceph_mon_network_index].ip)[0]
    }
    if vm.name != "bootstrap"
  ]

  _bootstrap_vms = [
    for vm in var.vms :
    vm.network_config[var.ceph_mon_network_index].ip
    if vm.name == "bootstrap"
  ]

  bootstrap_ip = length(local._bootstrap_vms) > 0 ? split("/", local._bootstrap_vms[0])[0] : "0.0.0.0"

  ceph_bootstrap_script = length(local._bootstrap_vms) > 0 ? templatefile(
    "${path.module}/templates/ceph-bootstrap.sh.tmpl",
    {
      ceph_nodes      = local.ceph_nodes
      bootstrap_ip    = local.bootstrap_ip
      cluster_network = var.ceph_cluster_network
      public_networks = join(",", var.ceph_public_networks)
      ceph_ssh_user   = var.ci_user
      ceph_ssh_pass   = var.ci_password
      domain          = var.domain
    }
  ) : ""

  katello_repos_script = var.katello_content_automation ? templatefile(
    "${path.module}/templates/katello-repos.sh.tmpl",
    {
      katello_gpg_keys        = var.katello_gpg_keys
      katello_yum_repos       = var.katello_yum_repos
      katello_deb_all         = concat(var.katello_deb_repos, var.katello_subscription_manager_deb_repos)
      katello_activation_keys = var.katello_activation_keys
    }
  ) : ""

  cloud_init_by_vm = {
    for vm in var.vms :
    vm.name => templatefile(
      "${path.module}/environments/${coalesce(vm.cloud_init_name, var.default_cloud_init_name)}",
      {
        hostname                     = vm.name
        domain                       = var.domain
        fqdn                         = var.domain != "" ? "${vm.name}.${var.domain}" : vm.name
        ceph_nodes                   = local.ceph_nodes
        ceph_bootstrap_script        = local.ceph_bootstrap_script
        proxy_url                    = var.proxy_url
        no_proxy                     = var.no_proxy
        katello_register_url         = var.katello_register_url
        enforce_disable_system_repos = var.enforce_disable_system_repos
        katello_repos_script         = local.katello_repos_script
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
    type        = "ssh"
    user        = var.sshuser
    password    = var.sshpass
    private_key = var.ssh_private_key != null ? file(var.ssh_private_key) : null
    host        = var.ssh_host != null ? var.ssh_host : var.proxmox_node
  }

  provisioner "file" {
    source      = local_file.cloud_init[each.key].filename
    destination = "${var.snippet_upload_dir}/${each.key}-cloud-init.yaml"
  }
}
