variable "prx_node" {
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

variable "vm_name" {
  type = string
}

variable "vm_memory" {
  type = number
}

variable "vm_mac" {
  type = string
}

variable "ssh_authorized_keys" {
  type = string
}

variable "ip_dns" {
  type    = string
  default = ""
}
