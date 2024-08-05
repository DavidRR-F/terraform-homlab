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
  default   = "~/.ssh/id_rsa.pub"
  sensitive = true
}

variable "ssh_private_key" {
  default   = "~/.ssh/id_rsa"
  sensitive = true
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "postgres" {
  type = map(any)
  default = {
    "vmid"      = 500
    "ip"        = "192.168.0.50"
    "count"     = 1
    "cores"     = 4
    "sockets"   = 2
    "memory"    = 8192
    "disk-size" = "100G"
  }
}
