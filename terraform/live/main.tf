# Main Terraform configuration for Hetzner Cloud infrastructure

locals {
  # Computed values
  server_name_prefix = "hetzner-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Data sources for existing resources
data "hcloud_network" "hvpc_1" {
  name = "hvpc-1"
}

data "hcloud_placement_group" "placement_group_1" {
  name = "placement-group-1"
}

data "hcloud_firewall" "k8s_lab" {
  name = "k8s-lab"
}

data "hcloud_ssh_key" "hetzner" {
  name = "Hetzner"
}

# Server module instance
module "server_lab" {
  source = "../modules/server"

  name        = "serverlab-${var.environment}-${var.location}"
  server_type = var.server_type
  image       = "ubuntu-22.04"
  location    = var.location
  ssh_keys    = var.ssh_keys
  user_data   = file("${path.module}/cloud-init.yml")

  placement_group_id = data.hcloud_placement_group.placement_group_1.id
  network_id         = data.hcloud_network.hvpc_1.id
  firewall_ids       = [data.hcloud_firewall.k8s_lab.id]

  labels = local.common_tags
}

# Add more resources here as the project grows