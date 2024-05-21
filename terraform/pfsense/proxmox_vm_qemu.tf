resource "proxmox_vm_qemu" "pfsense" {
  name                   = "pfSense"
  startup                = "order=1"
  target_node            = var.prx_node
  clone                  = "pfsensetpl"
  desc                   = "pfSense VM fully cloned from pfsensetpl"
  agent                  = 1
  boot                   = "order=virtio0;ide2;net0"
  cores                  = 2
  define_connection_info = false
  force_create           = true
  memory                 = 1024
  onboot                 = true
  qemu_os                = "l26"

  disks {
    virtio {
      virtio0 {
        disk {
          size      = 15
          storage   = "local"
          replicate = true
        }
      }
    }
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