terraform {
  required_version = ">= 0.13.0"
  backend "s3" {
    bucket                      = "tfstate"
    key                         = "terraform.tfstate"
    endpoint                    = var.minio_url
    region                      = "us-east-1"
    access_key                  = var.access_key
    secret_key                  = var.secret_key
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0.0"
    }
  }
}

provider "onepassword" {
  op_cli_path = var.op_cli_path
}

data "onepassword_item" "proxmox_credentials" {
  vault = var.vault_uuid
  title = "Proxmox Api"
}

provider "proxmox" {
  pm_api_url          = data.proxmox_credentials.url
  pm_api_token_id     = data.proxmox_credentials.username
  pm_api_token_secret = data.proxmox_credentials.credential
}

data "onepassword_item" "dns_credentials" {
  vault = var.vault_uuid
  title = "DNS Server"
}

provider "dns" {
  update {
    server        = data.dns_credentials.hostname
    key_name      = data.dns_credentials.key
    key_algorithm = data.dns_credentials.type
    key_secret    = data.dns_credentials.credential
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

  dns_zone = data.dns_credentials.dns_zone
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

  dns_zone = data.dns_credentials.dns_zone
}

module "slurm-cluster" {
  source = "./slurm-cluster"

  providers = {
    proxmox     = proxmox
    dns         = dns
    onepassword = onepassword
  }

  dns_zone   = data.dns_credentials.dns_zone
  vault_uuid = var.vault_uuid
}
