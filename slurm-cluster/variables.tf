variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts"
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "master" {
  type = map(any)
  default = {
    "vmid"      = 600
    "ip"        = "192.168.0.6"
    "count"     = 1
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 4096
    "disk-size" = "20G"
  }
}

variable "worker" {
  type = map(any)
  default = {
    "vmid"      = 700
    "ip"        = "192.168.0.7"
    "count"     = 2
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 4096
    "disk-size" = "20G"
  }
}
