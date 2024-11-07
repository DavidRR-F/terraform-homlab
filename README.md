# Terraform Homelab

This repository contains Terraform configuration files used to manage and automate various aspects of my homelab environment, including infrastructure provisioning on **Proxmox**, DNS management, and integration with **1Password** for secret management.

## Providers Used

### 1. [Proxmox](https://www.terraform.io/docs/providers/proxmox/index.html)
- Manages virtual machines, containers, and other Proxmox resources.
- The Proxmox provider allows Terraform to create, manage, and automate the lifecycle of virtualized environments on a Proxmox server.

### 2. [DNS](https://www.terraform.io/docs/providers/dns/index.html)
- Manages DNS records for internal or public domains.
- This provider helps automate DNS records, making it easy to deploy and manage web servers or other networked services.

### 3. [1Password](https://www.terraform.io/docs/providers/1password/index.html)
- Manages secrets and vaults in 1Password.
- Used to securely store and retrieve credentials, API keys, and other sensitive information.

### 4. [MinIO](https://www.terraform.io/docs/providers/minio/index.html)
- Manages terraform state with s3 compatibility
- Used to create remote persitent storage for terraform state

## Providers

- [Terraform](https://www.terraform.io/downloads)
- A **Proxmox** server running and accessible.
- A **DNS** provider (e.g., Cloudflare, AWS Route 53, Bind9, etc.) configured for your domain.
- An account with **1Password** and access to the relevant vaults.

Ensure the necessary API tokens or credentials for each provider stored in a 1Password Vault:

- **Proxmox**: API token for Proxmox instance.
- **DNS**: API key or credentials for DNS provider.
- **1Password**: 1Password cli integration.
- **MinIO**: Persistent state storage
