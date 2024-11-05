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

resource "dns_a_record_set" "slurm-master" {
  count = var.master.count
  zone  = var.dns_zone
  name  = "slurm-master-${count.index}"
  addresses = [
    "${var.master.ip}${count.index}"
  ]
}

resource "proxmox_vm_qemu" "slurm-master" {
  count       = var.master.count
  name        = "slurm-master-${count.index}"
  desc        = "slurm-master-node"
  vmid        = var.master.vmid + count.index
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
  ipconfig0 = "ip=${var.master.ip}${count.index}/24,gw=${var.gateway}"
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

  #  lifecycle {
  #    ignore_changes = [
  #      bootdisk,
  #    ]
  #  }
}

resource "dns_a_record_set" "slurm-worker" {
  count = var.worker.count
  zone  = var.dns_zone
  name  = "slurm-worker-${count.index}"
  addresses = [
    "${var.worker.ip}${count.index}"
  ]
}

resource "proxmox_vm_qemu" "slurm-worker" {
  count       = var.worker.count
  name        = "slurm-worker-${count.index}"
  desc        = "slurm-worker-node"
  vmid        = var.worker.vmid + count.index
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
  ipconfig0 = "ip=${var.worker.ip}${count.index}/24,gw=${var.gateway}"
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

  #  lifecycle {
  #    ignore_changes = [
  #      bootdisk,
  #    ]
  #  }
}

