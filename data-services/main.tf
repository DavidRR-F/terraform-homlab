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

resource "dns_a_record_set" "vault" {
  zone = var.dns_zone
  name = var.vault.name
  addresses = [
    var.vault.ip
  ]
}

resource "proxmox_vm_qemu" "vault" {
  name        = var.vault.name
  desc        = var.vault.desc
  vmid        = var.vault.vmid
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = var.vault.cores
  sockets = var.vault.sockets
  memory  = var.vault.memory

  agent = 1

  network {
    model  = var.vault.model
    bridge = var.vault.bridge
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.vault.partition
          size    = var.vault.disk-size
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = var.vault.partition
        }
      }
    }
  }

  scsihw   = var.vault.scsihw
  bootdisk = var.vault.bootdisk

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.vault.ip}/24,gw=${var.gateway}"
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

  lifecycle {
    ignore_changes = [
      bootdisk,
    ]
  }
}
