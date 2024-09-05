variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "dns_server" {
  type = string
}

variable "dns_key" {
  default = "tsig-key."
  type    = string
}

variable "dns_algorithm" {
  default = "hmac-sha256"
  type    = string
}

variable "dns_secret" {
  type      = string
  sensitive = true
}

variable "dns_zone" {
  type = string
}
