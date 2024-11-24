resource "dns_a_record_set" "authentik" {
  zone = var.dns_zone
  name = var.authentik.name
  addresses = [
    var.authentik.ip
  ]
}

resource "proxmox_vm_qemu" "authentik" {
  name        = "authentik"
  desc        = "authentik-server"
  vmid        = var.authentik.vmid
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = var.authentik.cores
  sockets = var.authentik.sockets
  memory  = var.authentik.memory

  agent = 1

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = var.authentik.disk-size
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.authentik.ip}/24,gw=${var.gateway}"
  ciuser    = var.ssh_user
  sshkeys   = var.ssh_public_key

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      host        = self.default_ipv4_address
    }
  }
}
