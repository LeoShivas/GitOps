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

# https://github.com/hashicorp/packer-plugin-proxmox/blob/main/docs/builders/iso.mdx
source "proxmox-iso" "main" {
  node                     = var.prx_node
  iso_download_pve         = true
  iso_url                  = var.iso_url
  iso_storage_pool         = "local"
  iso_checksum             = var.iso_checksum
  boot_command             = ["<up><tab> ADM_NAME=${var.adm_username} ADM_PWD=${bcrypt(var.adm_pwd)} ADM_SSH_PUBLIC_KEY=${replace(var.adm_ssh_public_key," ",local.sub_string)} SUB_STRING=${local.sub_string} inst.cmdline inst.ks=https://${var.github_token}@raw.githubusercontent.com/${var.github_repo}/${var.github_ref_name}/kickstart/ks-rocky9.cfg<enter><wait7m>"]
  http_directory           = "kickstart"
  insecure_skip_tls_verify = true
  memory                   = 8092
  cores                    = 6
  cpu_type                 = "host"
  os                       = "l26"
  network_adapters {
    bridge = "vmbr1"
  }
  disks {
    disk_size    = "50G"
    storage_pool = "local"
    type         = "sata"
  }
  template_name                = "rocky9tpl"
  template_description         = "Rocky 9.1 x86_64 minimal, generated on ${local.template-date}"
  unmount_iso                  = true
  onboot                       = true
  qemu_agent                   = true
  ssh_username                 = var.adm_username
  ssh_private_key_file         = "~/.ssh/id_rsa"
  ssh_timeout                  = "10m"
  ssh_host                     = "rocky9tpl"
  ssh_bastion_host             = var.bind_ip_address
  ssh_bastion_port             = var.bind_ssh_port
  ssh_bastion_username         = var.bind_ssh_user
  ssh_bastion_private_key_file = "~/.ssh/id_rsa"
}

build {
  sources = ["source.proxmox-iso.main"]
}
