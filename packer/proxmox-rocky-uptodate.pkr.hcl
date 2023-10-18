packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

local "template-date" {
  expression = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

local "sub_string" {
  expression = "@@@@@"
}
variable "iso_url" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "adm_pwd" {
  type    = string
  default = ""
}

variable "adm_username" {
  type    = string
  default = ""
}

variable "adm_ssh_public_key" {
  type    = string
  default = ""
}

variable "prx_node" {
  type    = string
  default = ""
}

variable "github_token" {
  type    = string
  default = ""
}

variable "github_repo" {
  type    = string
  default = ""
}

variable "github_ref_name" {
  type    = string
  default = ""
}

variable "bind_ip_address" {
  type    = string
  default = ""
}

variable "bind_ssh_port" {
  type    = number
  default = 22
}

variable "bind_ssh_user" {
  type    = string
  default = ""
}

variable "ip_address" {
  type    = string
  default = ""
}

# https://github.com/hashicorp/packer-plugin-proxmox/blob/main/docs/builders/clone.mdx
source "proxmox-clone" "main" {
  node                     = var.prx_node
  insecure_skip_tls_verify = true
  memory                   = 8192
  cores                    = 6
  cpu_type                 = "host"
  os                       = "l26"
  scsi_controller          = "virtio-scsi-single"
  network_adapters {
    model  = "virtio"
    bridge = "vmbr1"
  }
  clone_vm                     = "rocky9tpl"
  template_name                = "rocky9utdtpl"
  template_description         = "Rocky 9.1 x86_64 minimal up-to-date, generated on ${local.template-date}"
  onboot                       = false
  boot                         = "order=virtio0;ide2;net0"
  full_clone                   = true
  qemu_agent                   = true
  ssh_username                 = var.adm_username
  ssh_private_key_file         = "~/.ssh/id_rsa"
  ssh_timeout                  = "15m"
  ssh_host                     = var.ip_address
  ssh_bastion_host             = var.bind_ip_address
  ssh_bastion_port             = var.bind_ssh_port
  ssh_bastion_username         = var.bind_ssh_user
  ssh_bastion_private_key_file = "~/.ssh/id_rsa"
}

build {
  sources = ["source.proxmox-clone.main"]
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
    ]
  }
}
