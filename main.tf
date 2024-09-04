terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

module "k8s-cluster" {
  source = "./k8s-cluster"

  providers = {
    proxmox = proxmox
  }
}

module "web-services" {
  source = "./web-services"

  providers = {
    proxmox = proxmox
  }
}

module "data-services" {
  source = "./data-services"

  providers = {
    proxmox = proxmox
  }
}

module "bind9-vm" {
  source = "./bind9-vm"

  providers = {
    proxmox = proxmox
  }
}
