resource "proxmox_vm_qemu" "pfsense" {
  name                   = "pfSense"
  target_node            = var.prx_node
  clone                  = "pfsensetpl"
  desc                   = "pfSense VM fully cloned from pfsensetpl"
  agent                  = 1
  boot                   = "order=sata0;ide2;net0"
  cores                  = 2
  define_connection_info = false
  force_create           = true
  memory                 = 2048
  onboot                 = true

  disk {
    size    = "15G"
    storage = "local"
    type    = "sata"
  }

  network {
    bridge  = "vmbr0"
    macaddr = var.mac_address
    model   = "virtio"
  }

  network {
    bridge = "vmbr1"
    model  = "virtio"
  }
}