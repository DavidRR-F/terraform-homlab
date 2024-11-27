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

variable "authentik" {
  type = map(any)
  default = {
    "name"      = "authentik"
    "vmid"      = 400
    "ip"        = "192.168.0.40"
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 4096
    "disk-size" = "20G"
  }
}
