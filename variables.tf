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

variable "dns_zone" {
  type = string
}

variable "op_cli_path" {
  type = string
}

variable "vault_uuid" {
  type = string
}
