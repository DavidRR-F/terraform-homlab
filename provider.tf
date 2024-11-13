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
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
  }
}

provider "onepassword" {
  url         = terraform.workspace == "prod" ? var.op_token : null
  token       = terraform.workspace == "prod" ? var.op_token : null
  account     = terraform.workspace == "dev" ? var.op_account : null
  op_cli_path = terraform.workspace == "dev" ? var.op_cli_path : null
}

data "onepassword_item" "proxmox_credentials" {
  vault = var.vault_uuid
  title = "Proxmox Api"
}

provider "proxmox" {
  pm_api_url          = data.onepassword_item.proxmox_credentials.url
  pm_api_token_id     = data.onepassword_item.proxmox_credentials.username
  pm_api_token_secret = data.onepassword_item.proxmox_credentials.credential
}

data "onepassword_item" "dns_credentials" {
  vault = var.vault_uuid
  title = "DNS Server"
}

provider "dns" {
  update {
    server        = data.onepassword_item.dns_credentials.hostname
    key_name      = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret    = data.onepassword_item.dns_credentials.credential
  }
}
