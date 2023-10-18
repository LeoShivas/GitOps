data "tls_public_key" "public_key" {
  private_key_openssh = var.adm_private_key
}

resource "macaddress" "kube_cp" {
  count = var.kube_cp_count
}

resource "macaddress" "kube_wk" {
  count = var.kube_wk_count
}

locals {
  kube_vm_list = merge(
    local.kube_cp_list,
    local.kube_wk_list,
  )
  kube_cp_list = {
    for i in range(var.kube_cp_count) : "kube-cp-${i + 1}" => {
      vm_memory = 2048
      vm_mac    = macaddress.kube_cp[i].address
    }
  }
  kube_wk_list = {
    for i in range(var.kube_wk_count) : "kube-wk-${i + 1}" => {
      vm_memory = 2048
      vm_mac    = macaddress.kube_wk[i].address
    }
  }
}

module "kube_vm" {
  source   = "../kube/"
  for_each = local.kube_vm_list

  prx_node             = var.prx_node
  adm_username         = var.adm_username
  adm_pwd              = var.adm_pwd
  adm_private_key      = var.adm_private_key
  root_private_key     = var.root_private_key
  ssh_authorized_keys  = "${trimspace(data.tls_public_key.public_key.public_key_openssh)} runner@inserted-by-terraform"
  bind_ip_address      = var.bind_ip_address
  bind_ssh_port        = var.bind_ssh_port
  bind_ssh_user        = var.bind_ssh_user
  bind_ssh_private_key = var.bind_ssh_private_key
  vm_name              = each.key
  vm_memory            = each.value.vm_memory
  vm_mac               = each.value.vm_mac
  ip_dns               = var.ip_dns
}
