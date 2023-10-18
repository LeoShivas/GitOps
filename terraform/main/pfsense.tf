module "pfsense" {
  source = "../pfsense/"

  mac_address = var.mac_address
  prx_node    = var.prx_node
}
