terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    dns = {
      source = "hashicorp/dns"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

data "onepassword_item" "homelab_ssh" {
  vault = var.vault_uuid
  title = "Homelab Key"
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
  ciuser    = data.homelab_ssh.user
  sshkeys   = data.homelab_ssh.public_key

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]

    connection {
      type        = "ssh"
      user        = data.homelab_ssh.user
      private_key = data.homelab_ssh.private_key
      host        = self.default_ipv4_address
    }
  }

  lifecycle {
    ignore_changes = [
      bootdisk,
    ]
  }
}
