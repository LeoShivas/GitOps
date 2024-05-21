resource "null_resource" "cloud_init_user_data_file" {
  connection {
    user        = "root"
    private_key = var.root_private_key
    host        = var.prx_node
    port        = 22
  }

  provisioner "file" {
    content = templatefile(
      "../files/cloud-init/cloud-init.cloud_config_user.tftpl",
      {
        hostname            = var.vm_name,
        user                = var.adm_username,
        password            = var.adm_pwd,
        ssh_authorized_keys = var.ssh_authorized_keys,
      }
    )
    destination = "/var/lib/vz/snippets/user_data_vm-${var.vm_name}.yml"
  }

  triggers = {
    hostname            = var.vm_name,
    user                = var.adm_username,
    ssh_authorized_keys = var.ssh_authorized_keys,
    password            = var.adm_pwd,
  }
}

resource "null_resource" "cloud_init_network_data_file" {
  connection {
    user        = "root"
    private_key = var.root_private_key
    host        = var.prx_node
    port        = 22
  }

  provisioner "file" {
    content = templatefile(
      "../files/cloud-init/cloud-init.cloud_config_network.tftpl",
      {
        ip_dns = var.ip_dns,
      }
    )
    destination = "/var/lib/vz/snippets/network_data_vm-${var.vm_name}.yml"
  }

  triggers = {
    ip_dns = var.ip_dns,
  }
}

resource "proxmox_vm_qemu" "main" {
  name                   = var.vm_name
  target_node            = var.prx_node
  clone                  = "cirocky9tpl"
  desc                   = "Rocky Linux 9 VM fully cloned from cirocky9tpl"
  agent                  = 1
  cores                  = 8
  define_connection_info = false
  force_create           = true
  memory                 = var.vm_memory
  onboot                 = true
  qemu_os                = "l26"
  scsihw                 = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 {
        disk {
          size      = 50
          storage   = "local"
          replicate = true
        }
      }
    }
  }

  network {
    bridge  = "vmbr1"
    model   = "virtio"
    macaddr = var.vm_mac
  }

  os_type = "cloud-init"

  ciuser                  = var.adm_username
  cipassword              = var.adm_pwd
  sshkeys                 = var.ssh_authorized_keys
  cloudinit_cdrom_storage = "local"
  cicustom                = "user=local:snippets/user_data_vm-${var.vm_name}.yml,network=local:snippets/network_data_vm-${var.vm_name}.yml"

  provisioner "remote-exec" {
    connection {
      user                = var.adm_username
      private_key         = var.adm_private_key
      host                = self.name
      bastion_host        = var.bind_ip_address
      bastion_port        = var.bind_ssh_port
      bastion_user        = var.bind_ssh_user
      bastion_private_key = var.bind_ssh_private_key
    }
    inline = [
      "ip a"
    ]
  }

  depends_on = [
    null_resource.cloud_init_user_data_file,
    null_resource.cloud_init_network_data_file,
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.cloud_init_user_data_file,
      null_resource.cloud_init_network_data_file,
    ]
  }
}
