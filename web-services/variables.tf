variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts"
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "ssh_user" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "dns_zone" {
  type = string
}

variable "homepage" {
  type = map(any)
  default = {
    "name"      = "homepage"
    "vmid"      = 600
    "ip"        = "192.168.0.60"
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 6144
    "disk-size" = "20G"
  }
}
