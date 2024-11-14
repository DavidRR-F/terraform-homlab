resource "proxmox_vm_qemu" "bind9" {
  name        = var.bind9.name
  desc        = var.bind9.desc
  vmid        = var.bind9.vmid
  target_node = var.proxmox_host

  clone = var.template_ubuntu
  agent = 1

  cores   = var.bind9.cores
  sockets = var.bind9.sockets
  memory  = var.bind9.memory

  network {
    model  = var.bind9.model
    bridge = var.bind9.bridge
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.bind9.partition
          size    = var.bind9.disk-size
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = var.bind9.partition
        }
      }
    }
  }

  scsihw   = var.bind9.scsihw
  bootdisk = var.bind9.bootdisk

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.bind9.ip}/24,gw=${var.bind9.gateway}"
  ciuser    = var.ssh_user
  sshkeys   = var.ssh_public_key

  onboot = true

  provisioner "remote-exec" {
    inline = [
      "ip a",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      host        = var.bind9.ip
    }
  }
  lifecycle {
    ignore_changes = all
  }
}
