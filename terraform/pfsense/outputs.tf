output "vm_id" {
  value = tonumber(element(split("/", proxmox_vm_qemu.pfsense.id), length(split("/", proxmox_vm_qemu.pfsense.id)) - 1))
}
