packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

local "template_date" {
  expression = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

variable "virtual_mac" {
  type    = string
  default = ""
}

variable "iso_file" {
  type    = string
  default = ""
}

variable "ip_address" {
  type    = string
  default = ""
}

variable "ip_gateway" {
  type    = string
  default = ""
}

variable "pfsense_adm_pwd" {
  type    = string
  default = ""
}

variable "pfsense_ssh_port" {
  type    = number
  default = 22
}

variable "pfsense_adm_ssh_public_key" {
  type    = string
  default = ""
}

variable "prx_node" {
  type    = string
  default = ""
}

# https://github.com/hashicorp/packer-plugin-proxmox/blob/main/docs/builders/iso.mdx
source "proxmox-iso" "main" {
  node             = var.prx_node
  iso_download_pve = true
  iso_file         = "local:iso/${var.iso_file}"
  boot_command = [
    "<wait1m>",
    "<enter><wait1><enter><wait1><enter><wait1><enter><wait1><enter><wait1><enter><wait1>",
    "<spacebar><enter><wait1><left><enter><wait1m>",
    "<left><enter><wait1>",
    "head -n `grep -n -B 1 '</system>' /conf/config.xml|head -1|awk -F- '{print $1}'` /conf/config.xml > /conf/config.xml_tmp<enter>",
    "printf \"\\t\\t<ssh>\\n\" >> /conf/config.xml_tmp<enter>",
    "printf \"\\t\\t\\t<enable>enabled</enable>\\n\" >> /conf/config.xml_tmp<enter>",
    "printf \"\\t\\t\\t<port>${var.pfsense_ssh_port}</port>\\n\" >> /conf/config.xml_tmp<enter>",
    "printf \"\\t\\t</ssh>\\n\" >> /conf/config.xml_tmp<enter>",
    "grep -A `wc -l < /conf/config.xml` '</system>' /conf/config.xml >> /conf/config.xml_tmp<enter>",
    "mv /conf/config.xml_tmp /conf/config.xml<enter>",
    "exit<enter><wait1><enter><wait1m>",
    "n<enter><wait1>vtnet0<enter><wait1>vtnet1<enter><wait1>y<enter><wait3m>",
    "2<enter>1<enter>n<enter>${var.ip_address}<enter>32<enter>${var.ip_gateway}<enter>n<enter><enter>y<enter><wait5><enter>",
    "8<enter>",
    "pfSsh.php playback changepassword<enter><wait1>admin<enter><wait1>${var.pfsense_adm_pwd}<enter><wait1>${var.pfsense_adm_pwd}<enter>",
    "easyrule pass wan tcp any any ${var.pfsense_ssh_port}<enter>",
    "pkg install -y qemu-guest-agent<enter><wait20>",
    "echo 'qemu_guest_agent_enable=\"YES\"' >> /etc/rc.conf.local<enter>",
    "echo 'qemu_guest_agent_flags=\"-d -v -l /var/log/qemu-ga.log\"' >> /etc/rc.conf.local<enter>",
    "service qemu-guest-agent start<enter><wait1>",
    "echo \"service qemu-guest-agent start\" >> /usr/local/etc/rc.d/qemu-guest-agent.sh<enter>",
    "chmod +x /usr/local/etc/rc.d/qemu-guest-agent.sh<enter>",
    "exit<enter>",
  ]
  insecure_skip_tls_verify = true
  memory                   = 2048
  cores                    = 2
  cpu_type                 = "host"
  os                       = "l26"
  scsi_controller          = "virtio-scsi-single"
  network_adapters {
    model = "virtio"
    bridge      = "vmbr0"
    mac_address = var.virtual_mac
  }
  network_adapters {
    model = "virtio"
    bridge = "vmbr1"
  }
  disks {
    disk_size    = "15G"
    storage_pool = "local"
    type         = "virtio"
  }
  template_name        = "pfsensetpl"
  template_description = "pfSense, generated on ${local.template_date}"
  unmount_iso          = true
  onboot               = true
  qemu_agent           = true
  ssh_host             = var.ip_address
  ssh_username         = "admin"
  ssh_password         = var.pfsense_adm_pwd
  ssh_port             = var.pfsense_ssh_port
}

build {
  sources = ["source.proxmox-iso.main"]
  provisioner "shell" {
    inline = [
      "mkdir -p /root/.ssh",
      "chmod 700 /root/.ssh",
      "head -n `grep -n -B 1 '</system>' /conf/config.xml|head -1|awk -F- '{print $1}'` /conf/config.xml > /conf/config.xml_tmp",
      "printf \"\\t\\t<shellcmd>/usr/sbin/kbdcontrol -l /usr/share/syscons/keymaps/fr.iso.acc.kbd</shellcmd>\\n\" >> /conf/config.xml_tmp",
      "grep -A `wc -l < /conf/config.xml` '</system>' /conf/config.xml >> /conf/config.xml_tmp",
      "mv /conf/config.xml_tmp /conf/config.xml",
      "head -n `grep -n user-shell-access /conf/config.xml|awk -F: '{print $1}'` /conf/config.xml > /conf/config.xml_tmp",
      "printf \"\\t\\t\\t<authorizedkeys>`php -r 'echo base64_encode(\"${var.pfsense_adm_ssh_public_key}\");'`</authorizedkeys>\\n\" >> /conf/config.xml_tmp",
      "/bin/sh -c \"tail -n $(expr `wc -l /conf/config.xml|awk '{print $1}'` - `grep -n user-shell-access /conf/config.xml|awk -F: '{print $1}'`) /conf/config.xml >> /conf/config.xml_tmp\"",
      "mv /conf/config.xml_tmp /conf/config.xml",
      "rm /tmp/config.cache",
    ]
  }

}
