variable "hcloud_token" {
  description = "Hetzner Cloud API token for authentication"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.hcloud_token) > 0
    error_message = "Hetzner Cloud API token must not be empty."
  }
}

variable "location" {
  description = "Hetzner datacenter location (e.g., hel1, fsn1, nbg1)"
  type        = string
  default     = "hil"
  validation {
    condition = contains([
      "hel1", "fsn1", "nbg1", "ash", "hil"
    ], var.location)
    error_message = "Location must be a valid Hetzner datacenter."
  }
}

variable "server_type" {
  description = "Hetzner server type (e.g., cx11, cpx11)"
  type        = string
  default     = "cpx21"
  validation {
    condition     = length(var.server_type) > 0
    error_message = "Server type must not be empty."
  }
}
variable "server_name" {
  description = "Name of the server"
  type        = string
  #default     = "serverlab"
  validation {
    condition     = length(var.server_name) > 0
    error_message = "Server name must not be empty."
  }
}

variable "image" {
  description = "Image ID or name for the server (e.g., ubuntu-22.04)"
  type        = string
  default     = "ubuntu-22.04"
  validation {
    condition     = length(var.image) > 0
    error_message = "Image must not be empty."
  }
}

variable "ssh_keys" {
  description = "List of SSH key names to add to servers"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition = contains([
      "dev", "staging", "prod"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "ssh_private_key" {
  description = "SSH private key for Ansible to connect to worker nodes (stored in HCP Terraform as sensitive variable)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.ssh_private_key) > 0
    error_message = "SSH private key must not be empty."
  }
}