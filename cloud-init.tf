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
      katello_gpg_keys             = var.katello_gpg_keys
      katello_yum_repos            = var.katello_yum_repos
      katello_deb_all              = concat(var.katello_deb_repos, var.katello_debian_repos, var.katello_subscription_manager_deb_repos)
      katello_activation_keys      = var.katello_activation_keys
      foreman_proxmox_integration  = var.foreman_proxmox_integration
      foreman_proxmox_name         = var.foreman_proxmox_name
      foreman_proxmox_server       = var.foreman_proxmox_server
      foreman_proxmox_user         = var.foreman_proxmox_user
      foreman_proxmox_auth_method  = var.foreman_proxmox_auth_method
      foreman_proxmox_token_id     = var.foreman_proxmox_token_id
      foreman_proxmox_password     = var.foreman_proxmox_password
      foreman_compute_profiles     = var.foreman_compute_profiles
      foreman_compute_profile_list = var.foreman_compute_profile_list
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

  # OmniOS-specific per-VM user-data (cicustom user=)
  omnios_user_data_by_vm = {
    for vm in var.omnios_vms :
    vm.name => templatefile(
      "${path.module}/templates/omnios-base-user-data.yaml.tmpl",
      {
        hostname       = vm.name
        fqdn           = var.domain != "" ? "${vm.name}.${var.domain}" : vm.name
        domain         = var.domain
        nameserver     = var.omnios_nameserver != "" ? var.omnios_nameserver : "192.168.2.2"
        ssh_keys_block = join("\n", [for line in compact(split("\n", file("${path.module}/ssh_keys.txt"))) : "      - ${line}"])
        static_net_runcmd = vm.network_config[0].ip == "dhcp" ? "" : join("\n", [
          "    /usr/sbin/ipadm delete-addr eth0/dhcp 2>/dev/null || true",
          "    /usr/sbin/ipadm delete-if eth0 2>/dev/null || true",
          "    /usr/sbin/ipadm create-if eth0",
          "    /usr/sbin/ipadm create-addr -T static -a ${vm.network_config[0].ip} eth0/v4",
          "    /usr/sbin/route -p delete default 2>/dev/null || true",
          "    /usr/sbin/route -p add default ${vm.network_config[0].gateway}",
        ])
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

# OmniOS per-VM user-data snippet upload (cicustom user=)
resource "local_file" "omnios_user_data" {
  for_each = local.omnios_user_data_by_vm

  content  = each.value
  filename = "${path.module}/files/${each.key}-omnios-user-data.yaml"
}

resource "null_resource" "omnios_user_data" {
  for_each = local.omnios_user_data_by_vm

  triggers = {
    checksum = sha256(each.value)
  }

  depends_on = [local_file.omnios_user_data]

  connection {
    type        = "ssh"
    user        = var.sshuser
    password    = var.sshpass
    private_key = var.ssh_private_key != null ? file(var.ssh_private_key) : null
    host        = var.ssh_host != null ? var.ssh_host : var.proxmox_node
  }

  provisioner "file" {
    source      = local_file.omnios_user_data[each.key].filename
    destination = "${var.snippet_upload_dir}/${each.key}-omnios-user-data.yaml"
  }
}
