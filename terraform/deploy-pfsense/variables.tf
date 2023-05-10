variable "prx_node" {
  type = string
}

variable "mac_address" {
  type = string
}

locals {
  expression = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}
