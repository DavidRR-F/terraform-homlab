variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts"
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

variable "bind9" {
  type = map(any)
  default = {
    "name"      = "dns-server"
    "desc"      = "Bind9 DNS Server"
    "vmid"      = 300
    "cores"     = 2
    "sockets"   = 1
    "memory"    = 4096
    "ip"        = "192.168.0.30"
    "gateway"   = "192.168.0.1"
    "model"     = "virtio"
    "bridge"    = "vmbr0"
    "partition" = "local-lvm"
    "disk-size" = "20G"
    "bootdisk"  = "scsi0"
    "scsihw"    = "virtio-scsi-single"
  }
}

variable "named_config" {
  type = map(any)
  default = {
    "forwarders" = ["1.1.1.2", "1.0.0.2"]
    "acl"        = ["192.168.0.0/24", "10.0.0.0/8"]
  }
}
