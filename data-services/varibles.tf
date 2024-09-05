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

variable "dns_zone" {
  type = string
}

variable "vault" {
  type = map(any)
  default = {
    "name"      = "vault"
    "desc"      = "HashiCorp Vault Server"
    "vmid"      = 500
    "ip"        = "192.168.0.50"
    "count"     = 1
    "cores"     = 2
    "sockets"   = 1
    "memory"    = 4096
    "disk-size" = "20G"
    "model"     = "virtio"
    "bridge"    = "vmbr0"
    "partition" = "local-lvm"
    "scsihw"    = "virtio-scsi-single"
    "bootdisk"  = "scsi0"
  }
}
