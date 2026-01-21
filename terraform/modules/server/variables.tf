variable "name" {
  description = "Name of the server"
  type        = string
}

variable "server_type" {
  description = "Hetzner server type (e.g., cx11, cpx21)"
  type        = string
}

variable "image" {
  description = "Image ID or name for the server"
  type        = string
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
}

variable "ssh_keys" {
  description = "List of SSH key names to add to the server"
  type        = list(string)
  default     = ["Hetzner"]
}
variable "ssh_pub_key" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/telemaco-com.pub"
}

variable "user_data" {
  description = "Cloud-init user data for server initialization"
  type        = string
  default     = ""
}

variable "placement_group_id" {
  description = "ID of the placement group to assign the server to"
  type        = string
  default     = null
}

variable "network_id" {
  description = "ID of the network to attach the server to"
  type        = string
  default     = null
}

variable "firewall_ids" {
  description = "List of firewall IDs to attach to the server"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the server"
  type        = map(string)
  default     = {}
}