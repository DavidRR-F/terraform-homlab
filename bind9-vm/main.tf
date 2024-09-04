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
  zonefile        = replace(var.subdomain, ".", "-")
}

output "ssh_public_key" {
  value     = local.ssh_public_key
  sensitive = true
}

output "ssh_private_key" {
  value     = local.ssh_private_key
  sensitive = true
}

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
  sshkeys   = local.ssh_public_key

  onboot = true

  provisioner "remote-exec" {
    inline = [
      "ip a",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf",
      "sudo systemctl restart systemd-resolved",
      "mkdir -p /home/${var.ssh_user}/bind",
      "chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/bind"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/named.conf.tftpl", {
      forwarders = var.named_config.forwarders,
      acl        = var.named_config.acl,
      zone       = var.subdomain,
      key        = var.tsig_key,
      zonefile   = local.zonefile
    })
    destination = "/home/${var.ssh_user}/bind/named.conf"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/zone.tftpl", {
      zone    = var.subdomain,
      email   = var.email,
      ip      = var.bind9.ip,
      host_ip = var.proxmox_ip
      serial  = "0000000001"
    })
    destination = "/home/${var.ssh_user}/bind/${local.zonefile}.zone"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/docker.tftpl", {
      image = var.bind9.docker_image
    })
    destination = "/home/${var.ssh_user}/docker-compose.yaml"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker compose -f /home/${var.ssh_user}/bind/docker-compose.yml up -d"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.ip
    }
  }

  lifecycle {
    ignore_changes = [
      bootdisk,
    ]
  }
}
