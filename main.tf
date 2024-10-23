terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

provider "dns" {
  update {
    server        = var.dns_server
    key_name      = var.dns_key
    key_algorithm = var.dns_algorithm
    key_secret    = var.dns_secret
  }
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
    dns     = dns
  }

  dns_zone = var.dns_zone
}

module "network-services" {
  source = "./network-services"

  providers = {
    proxmox = proxmox
  }
}

module "security-services" {
  source = "./security-services"

  providers = {
    proxmox = proxmox
    dns     = dns
  }

  dns_zone = var.dns_zone
}
