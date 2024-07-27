variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts"
}

variable "ssh_user" {
  default = "admin"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa"
}

variable "master" {
  type = map(string)
  default = {
    "count"     = 1
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 4096
    "disk-size" = "20G"
  }
}

variable "worker" {
  type = map(string)
  default = {
    "count"     = 2
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 4096
    "disk-size" = "20G"
  }
}
