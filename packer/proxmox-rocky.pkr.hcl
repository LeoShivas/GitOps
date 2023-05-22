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

variable "iso_url" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "pkr_pwd" {
  type    = string
  default = ""
}

variable "pkr_username" {
  type    = string
  default = ""
}

variable "prx_node" {
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
  boot_command             = ["<up><tab> PKR_NAME=${var.pkr_username} PKR_PWD=${bcrypt(var.pkr_pwd)} inst.cmdline inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart/ks-rocky9.cfg<enter>"]
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
  template_name        = "rockytpl"
  template_description = "Rocky 9.1 x86_64 minimal, generated on ${local.template-date}"
  unmount_iso          = true
  onboot               = true
  qemu_agent           = true
  ssh_username         = var.pkr_username
  ssh_password         = var.pkr_pwd
}

build {
  sources = ["source.proxmox-iso.main"]
}
