resource "proxmox_lxc" "container" {
  target_node  = "minase"
  vmid         = 113
  hostname     = "openclaw"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  unprivileged = true
  pool         = "terraform"
  cores        = 2
  memory       = 2048
  swap         = 2048
  onboot       = true
  start        = true
  tags         = "service;ubuntu"

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGm/Kxkt6dE/GZ5yYrxj0Uw3ugcm8o1YsjLmGEA9Rn3u minase@takatsuki
  EOT

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.0.113/24"
    gw     = "192.168.0.1"
  }

  rootfs {
    storage = "local-lvm"
    size    = "16G"
  }
}
