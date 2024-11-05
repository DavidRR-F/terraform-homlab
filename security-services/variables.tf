variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts"
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "dns_zone" {
  type = string
}

variable "keycloak" {
  type = map(any)
  default = {
    "name"      = "keycloak"
    "desc"      = "IAM Server"
    "vmid"      = 400
    "ip"        = "192.168.0.40"
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
