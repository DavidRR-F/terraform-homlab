terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    docker = {
      source = "kreuzwerker/docker"
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

resource "proxmox_vm_qemu" "bind9" {
  name = var.bind9.name
  desc = var.bind9.desc
  vmid = var.bind9.vmid

  agent = 1

  network {
    model  = var.bind9.network.model
    bridge = var.bind9.network.bridge
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.bind9.storage.partition
          size    = var.bind9.storage.disk-size
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = var.bind9.storage.partition
        }
      }
    }
  }

  scsihw   = var.bind9.storage.scsihw
  bootdisk = var.bind9.storage.bootdisk

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.bind9.network.ip}/24,gw=${var.bind9.network.gateway}"
  ciuser    = var.ssh_user
  sshkeys   = local.ssh_public_key

  onboot = true

  provisioner "remote-exec" {
    inline = [
      "ip a",
      "sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf",
      "systemctl restart systemd-resolved",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.network.ip
    }
  }

}

resource "null_resource" "wait_for_docker" {
  provisioner "remote-exec" {
    inline = [
      "while ! sudo systemctl is-active --quiet docker; do sleep 1; done"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = local.ssh_private_key
      host        = var.bind9.network.ip
    }
  }

  depends_on = [proxmox_vm_qemu.bind9]
}

provider "docker" {
  host       = "ssh://${var.ssh_user}@${var.bind9.network.ip}"
  ssh_opts   = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  depends_on = [null_resource.wait_for_docker]
}

resource "local_file" "named_conf" {
  content = templatefile("${path.module}/templates/named.conf.tpl", {
    forwaders = var.bind9.config.forwarders,
    acl       = var.bind9.config.acl,
    zone      = var.bind9.config.zone,
    key       = var.tsig_key,
    zonefile  = replace(var.subdomain, ".", "-")
  })
  filename   = "/etc/bind/named.conf"
  depends_on = [proxmox_vm_qemu.bind9]
}

resource "local_file" "zone" {
  content = templatefile("${path.module}/templates/zone.tpl", {
    zone   = var.subdomain,
    email  = var.email,
    ip     = var.bind9.network.ip,
    hostip = var.proxmox_ip
    serial = formatdate("YYYYMMDDhh", timestamp())
  })
  filename   = "/etc/bind/${replace(var.subdomain, ".", "-")}.zone"
  depends_on = [proxmox_vm_qemu.bind9]
}

resource "docker_image" "bind9" {
  name       = var.bind9.docker.image
  depends_on = [null_resource.wait_for_docker]
}

resource "docker_container" "bind9" {
  image = var.bind9.docker.image
  name  = var.bind9.docker.name

  env = [
    "BIND9_USER=root",
    "TZ=America/New_York"
  ]

  ports {
    internal = var.bind9.docker.port
    external = var.bind9.docker.port
    protocol = "udp"
  }

  ports {
    internal = var.bind9.docker.port
    external = var.bind9.docker.port
    protocol = "tcp"
  }

  dynamic "volumes" {
    for_each = var.bind9.docker.volumes
    content {
      container_path = volumes.value
      host_path      = volumes.value
    }
  }

  restart = "unless-stopped"

  depends_on = [null_resource.wait_for_docker]
}
