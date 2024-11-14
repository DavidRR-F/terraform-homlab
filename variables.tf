variable "op_url" {
  type = string
}

variable "op_account" {
  type = string
}

variable "op_cli_path" {
  type = string
}

variable "op_token" {
  type      = string
  sensitive = true
}

variable "vault_uuid" {
  type = string
}

variable "proxmox_url" {
  type = string
}

variable "dns_zone" {
  type = string
}
