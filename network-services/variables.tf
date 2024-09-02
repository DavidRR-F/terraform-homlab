variable "proxmox_host" {
  default = "proxmox"
}

variable "template_ubuntu" {
  default = "ubuntu-2404lts-docker"
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

variable "email" {
  default   = ""
  sensitive = true
}

variable "subdomain" {
  default   = ""
  sensitive = true
}

variable "tsig_key" {
  default   = ""
  sensitive = true
}

variable "proxmox_ip" {
  default = ""
}

variable "bind9" {
  type = map(any)
  default = {
    "name" = "dns-server"
    "desc" = "Bind9 DNS Server"
    "vmid" = 300
    "compute" = {
      "cores"   = 2
      "sockets" = 2
      "memory"  = 6144
    }
    "network" = {
      "ip"      = "192.168.0.30"
      "gateway" = "192.168.0.1"
      "model"   = "virtio"
      "bridge"  = "vmbr0"
    }
    "storage" = {
      "partition" = "local-lvm"
      "disk-size" = "20G"
      "bootdisk"  = "scsi0"
      "scsihw"    = "virtio-scsi-single"
    }
    "config" = {
      "forwarders" = ["1.1.1.2", "1.0.0.2"]
      "acl"        = ["192.168.0.0/24", "10.0.0.0/8"]
    }
    "docker" = {
      "image" = "ubuntu/bind9:latest"
      "name"  = "dns-server-bind9"
      "port"  = 53
      "volumes" = [
        "/etc/bind",
        "/var/lib/bind",
        "/var/cache/bind"
      ]
    }
  }
}
