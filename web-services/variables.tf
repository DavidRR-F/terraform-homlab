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

variable "gitlab" {
  type = map(any)
  default = {
    "vmid"      = 600
    "ip"        = "192.168.0.60"
    "cores"     = 2
    "sockets"   = 2
    "memory"    = 6144
    "disk-size" = "20G"
  }
}
