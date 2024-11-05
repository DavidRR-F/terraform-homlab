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
