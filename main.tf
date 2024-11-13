data "onepassword_item" "homelab_ssh" {
  vault = var.vault_uuid
  title = "Homelab Key"
}

module "web-services" {
  source = "./web-services"
  providers = {
    proxmox = proxmox
    dns     = dns
  }
  dns_zone        = var.dns_zone
  ssh_user        = data.onepassword_item.homelab_ssh.username
  ssh_public_key  = data.onepassword_item.homelab_ssh.public_key
  ssh_private_key = data.onepassword_item.homelab_ssh.private_key
}

module "network-services" {
  source = "./network-services"
  providers = {
    proxmox = proxmox
  }
  ssh_user        = data.onepassword_item.homelab_ssh.username
  ssh_public_key  = data.onepassword_item.homelab_ssh.public_key
  ssh_private_key = data.onepassword_item.homelab_ssh.private_key
}
