# OpenTofu Multi-VM Proxmox Deployment

OpenTofu configurations for deploying multiple VM environments on Proxmox VE from one shared codebase.

The repository supports environment-specific `.tfvars` files, per-environment state files, per-VM cloud-init overrides, and Proxmox snippet upload for custom cloud-init vendor data.

## Features

- Multiple environments via `environments/*.tfvars`
- Separate state files per environment
- Per-VM cloud-init override with `cloud_init_name`
- Proxmox snippet upload via SSH
- Multi-NIC and VLAN support
- Additional SCSI and VirtIO disks per VM
- Ceph example with dedicated bootstrap and OSD cloud-init files

## Prerequisites

- OpenTofu installed
- Proxmox VE API access
- SSH access to the Proxmox host for snippet upload
- A cloud-init enabled VM template in Proxmox
- An `ssh_keys.txt` file in the repository root

## Required Files

### `terraform.tfvars`

Create a local `terraform.tfvars` with your Proxmox credentials.

Example with SSH password authentication:

```hcl
proxmox_api_url          = "https://PROXMOX:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "your-token-secret"
proxmox_node             = "pve"
sshuser                  = "root"
sshpass                  = "your-password"
snippet_storage_id       = "cephfs"
snippet_upload_dir       = "/mnt/pve/cephfs/cloud-init/snippets"
```

Example with SSH key authentication:

```hcl
proxmox_api_url          = "https://PROXMOX:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "your-token-secret"
proxmox_node             = "pve"
sshuser                  = "root"
ssh_private_key          = "~/.ssh/id_rsa"
snippet_storage_id       = "cephfs"
snippet_upload_dir       = "/mnt/pve/cephfs/cloud-init/snippets"
```

### `ssh_keys.txt`

Create `ssh_keys.txt` in the repository root. It is intentionally not committed and is listed in `.gitignore`.

Example:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@example
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... user@example
```

These keys are injected into all VMs via cloud-init.

## Quick Start

```bash
tofu init --lock=false
```

Plan an environment:

```bash
tofu plan \
  -var-file="environments/ceph.tfvars" \
  -state="ceph.tfstate" \
  --lock=false
```

Apply an environment:

```bash
tofu apply \
  -var-file="environments/ceph.tfvars" \
  -state="ceph.tfstate" \
  --lock=false
```

Destroy an environment:

```bash
tofu destroy \
  -var-file="environments/ceph.tfvars" \
  -state="ceph.tfstate" \
  --lock=false
```

`--lock=false` is useful on SMB/NFS shares that do not support file locking.

## Environment Files

Environment definitions live in `environments/`.

Common examples:

- `ceph.tfvars`
- `dev.tfvars`
- `docker.tfvars`
- `katello.tfvars`
- `openstack-allinone.tfvars`
- `openstack-multinode-dev.tfvars`

An environment file contains only environment-specific values, not your Proxmox credentials.

Example:

```hcl
vm_template          = "rocky-9-ci-template"
storage              = "zfs_vms"
ceph_cluster_network = "192.168.30.0/24"
domain               = "local"

vms = [
  {
    name            = "bootstrap"
    vmid            = 9301
    cloud_init_name = "cephadm-cloud-init.yaml"
    cores           = 4
    sockets         = 1
    memory          = 8192
    disk_size       = "50G"
    additional_disks = []

    network_config = [
      { model = "virtio", bridge = "vmbr0", vlan = 0, ip = "192.168.2.150/24", gateway = "192.168.2.1" },
      { model = "virtio", bridge = "vmbr0", vlan = 50, ip = "192.168.30.150/24", gateway = "192.168.30.1" }
    ]

    description = "Bootstrap Node"
    tags        = ["bootstrap", "ceph"]
  }
]
```

## Ceph Notes

The Ceph example currently uses:

- `cephadm-cloud-init.yaml` for the bootstrap node
- `cephadm-osd-cloud-init.yaml` for OSD nodes
- `ceph_cluster_network` as an environment variable

The Ceph bootstrap script template uses:

- `bootstrap_ip` derived from the bootstrap VM network config
- `ceph_cluster_network` from the environment file
- FQDN hostnames when adding OSD hosts to Ceph

There is no separate Terraform variable for Ceph `public_network` yet. In the current setup, cephadm infers the public network from the bootstrap monitor IP passed via `--mon-ip`.

## Katello Content Automation

The `katello` environment provisions not only the Foreman/Katello server but also a
catalog of content, driven by these variables (all defaults live in `variables.tf`):

- `katello_content_automation` (default `true`) - master switch; when `false` no
  content is created and the cloud-init file omits the repo setup script entirely.
- `katello_gpg_keys` - content credentials imported into Katello
  (ATIX GPG key, Rocky 8/9/10 keys).
- `katello_yum_repos` - Rocky Linux 8/9/10 (BaseOS, AppStream, CRB - called
  `PowerTools` on Rocky 8, Extras), `gpg_key` attached per repository.
- `katello_deb_repos` - Ubuntu 20.04 / 22.04 / 24.04 / 26.04 (`focal`, `jammy`,
  `noble`, `resolute`) each with Base, Updates and Security (main, restricted,
  universe, multiverse).
- `katello_subscription_manager_deb_repos` - a dedicated product
  (`ATIX Subscription Manager`) holding the ATIX `subscription-manager` repositories
  required to register Ubuntu hosts with Katello (one repository per release).
- `katello_activation_keys` (default `true`) - after the repositories exist the
  setup creates a rolling content view per product (containing all repositories of
  that product), publishes it and creates an activation key `AK <product>` pointed
  at the content view + the `Library` lifecycle environment.

All repositories use `download_policy = "on_demand"`, so package content is only
downloaded from upstream when a registered host actually consumes it (metadata is
synced in the background at setup time).

The setup script runs from the `katello` cloud-init file right after
`foreman-installer` (`/root/katello-repos.sh`, log `/root/katello-repos.log`);
it is idempotent and can be re-run manually.

## Cloud-Init Layout

Relevant files:

- `cloud-init.tf`
- `environments/default-cloud-init.yaml`
- `environments/cephadm-cloud-init.yaml`
- `environments/cephadm-osd-cloud-init.yaml`
- `templates/ceph-bootstrap.sh.tmpl`

Cloud-init snippets are rendered locally into `files/*.yaml` and then copied to the Proxmox snippets directory.

Snippet storage defaults: `snippet_storage_id = "dir01"` with `snippet_upload_dir = "/mnt/pve/dir01/snippets"`
(e.g. a `dir` storage with `content snippets` mounted under `/mnt/pve/dir01`). Older deployments on this lab used
`local:snippets` (`/var/lib/vz/snippets`) and a short-lived `cephfs` storage id that no longer exists.
If the current storage differs, override both values in `terraform.tfvars`.
The VM gets `cicustom = vendor=<snippet_storage_id>:snippets/<vm-name>-cloud-init.yaml` unless
`cicustom_vendor` is set, which overrides the whole `cicustom` value per environment.

## Repository Structure

```text
.
├── cloud-init.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
├── ssh_keys.txt
├── templates/
│   └── ceph-bootstrap.sh.tmpl
├── environments/
│   ├── default-cloud-init.yaml
│   ├── cephadm-cloud-init.yaml
│   ├── cephadm-osd-cloud-init.yaml
│   ├── ceph.tfvars
│   └── ...
├── files/
└── README.md
```

## Useful Commands

```bash
tofu fmt
tofu validate
tofu show -state="ceph.tfstate"
tofu state list -state="ceph.tfstate"
tofu output -state="ceph.tfstate"
```

## Troubleshooting

### Cloud-init snippet upload fails

Check:

- `sshuser`
- `sshpass` or `ssh_private_key`
- SSH access to the Proxmox host
- that the Proxmox snippets directory exists and is writable
- `ssh_host`: by default the SSH connection for the snippet upload targets the node name
  (`proxmox_node`, e.g. `pve`). That only works when the web name is resolvable from the
  workstation running OpenTofu. Set `ssh_host = "192.168.2.11"` (node IP) if in doubt.

### VLAN tags are not applied to the VM NICs

The `tag` value in `network_config` is only applied if the target bridge is VLAN aware:

```text
iface vmbr0 inet static
    ...
    bridge-vlan-aware yes
    bridge-vids 2-4094
```

If the bridge is not VLAN aware (or the NIC tag was added after creation and
`lifecycle { ignore_changes = [network] }` masks it), the VM stays flat on the bridge.
Currently `vmbr0` on `pve` has **no** `bridge-vlan-aware yes` line, so all VLAN-tagged
network entries in the environment files (Ceph 192.168.30.x/192.168.40.x, etc.) run
untagged on the LAN until that is fixed.

### Cloud-init changes do not appear inside an existing VM

Cloud-init usually runs only once on first boot. If the VM already finished cloud-init, you need to recreate the VM or manually clean and rerun cloud-init inside the guest.

### SMB/NFS execution issues on macOS

If provider binaries cannot execute from a network share, use a local plugin cache:

```bash
mkdir -p ~/.terraform.d/plugin-cache
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
rm -rf .terraform .terraform.lock.hcl
tofu init
```

## License

MIT — see [LICENSE](LICENSE). Feel free to use the patterns, keep your own values per environment.
