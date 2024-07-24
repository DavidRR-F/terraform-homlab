terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

resource "proxmox_vm_qemu" "airflow" {
  name        = "airflow"
  vmid        = 200
  desc        = "airflow-web-service"
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = 2
  sockets = 1
  memory  = 2048

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
          size    = "20G"
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
  ipconfig0 = "ip=192.168.0.70/24,gw=192.168.0.1"
  ciuser    = var.ssh_user
  sshkeys   = <<EOF
  ${file(var.ssh_public_key)}
  EOF

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = self.default_ipv4_address
    }
  }
}

resource "proxmox_vm_qemu" "gitlab" {
  name        = "gitlab"
  desc        = "gitlab-web-service"
  vmid        = 201
  target_node = var.proxmox_host

  onboot = true

  clone = var.template_ubuntu

  cores   = 2
  sockets = 1
  memory  = 2048

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
          size    = "20G"
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
  ipconfig0 = "ip=192.168.0.71/24,gw=192.168.0.1"
  ciuser    = var.ssh_user
  sshkeys   = <<EOF
  ${file(var.ssh_public_key)}
  EOF

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = self.default_ipv4_address
    }
  }
}
