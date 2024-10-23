terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    dns = {
      source = "hashicorp/dns"
    }
  }
}

locals {
  ssh_public_key  = file(var.ssh_public_key)
  ssh_private_key = file(var.ssh_private_key)
}

output "ssh_public_key" {
  value     = local.ssh_public_key
  sensitive = true
}

output "ssh_private_key" {
  value     = local.ssh_private_key
  sensitive = true
}

resource "dns_a_record_set" "keycloak" {
  zone = var.dns_zone
  name = var.keycloak.name
  addresses = [
    var.keycloak.ip
  ]
}

resource "proxmox_vm_qemu" "keycloak" {
  name        = var.keycloak.name
  desc        = var.keycloak.desc
  vmid        = var.keycloak.vmid
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = var.keycloak.cores
  sockets = var.keycloak.sockets
  memory  = var.keycloak.memory

  agent = 1

  network {
    model  = var.keycloak.model
    bridge = var.keycloak.bridge
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.keycloak.partition
          size    = var.keycloak.disk-size
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = var.keycloak.partition
        }
      }
    }
  }

  scsihw   = var.keycloak.scsihw
  bootdisk = var.keycloak.bootdisk

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.keycloak.ip}/24,gw=${var.gateway}"
  ciuser    = var.ssh_user
  sshkeys   = local.ssh_public_key

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = self.default_ipv4_address
    }
  }

  //  lifecycle {
  //    ignore_changes = [
  //      bootdisk,
  //    ]
  //  }
}
