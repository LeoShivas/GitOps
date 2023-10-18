variable "prx_node" {
  type = string
}

variable "mac_address" {
  type = string
}

variable "adm_username" {
  type = string
}

variable "adm_pwd" {
  type = string
}

variable "adm_private_key" {
  type = string
}

variable "root_private_key" {
  type = string
}

variable "bind_ip_address" {
  type = string
}

variable "bind_ssh_port" {
  type = number
}

variable "bind_ssh_user" {
  type = string
}

variable "bind_ssh_private_key" {
  type = string
}

variable "kube_cp_count" {
  type = number
}

variable "kube_wk_count" {
  type = number
}

variable "ip_dns" {
  type    = string
  default = ""
}
