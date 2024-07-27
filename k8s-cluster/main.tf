terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
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

resource "proxmox_vm_qemu" "k8s-master" {
  count       = var.master.count
  name        = "k8s-master-${count.index}"
  desc        = "k8s-master-node"
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = var.master.cores
  sockets = var.master.sockets
  memory  = var.master.memory

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
          size    = var.master.disk-size
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
  ipconfig0 = "ip=192.168.0.9${count.index}/24,gw=192.168.0.1"
  ciuser    = var.ssh_user
  sshkeys   = <<EOF
  ${local.ssh_public_key}
  EOF

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
}

resource "proxmox_vm_qemu" "k8s-worker" {
  count       = var.worker.count
  name        = "k8s-worker-${count.index}"
  desc        = "k8s-worker-node"
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = var.worker.cores
  sockets = var.worker.sockets
  memory  = var.worker.memory

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
          size    = var.worker.disk-size
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
  ipconfig0 = "ip=192.168.0.8${count.index}/24,gw=192.168.0.1"
  ciuser    = var.ssh_user
  sshkeys   = <<EOF
  ${local.ssh_public_key}
  EOF

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
}
