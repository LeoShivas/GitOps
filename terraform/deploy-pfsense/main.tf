terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.0"
    }
  }
  cloud {}
}

provider "proxmox" {
}