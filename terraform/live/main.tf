# Main Terraform configuration for Hetzner Cloud infrastructure

locals {
  # Computed values
  server_name_prefix = "hetzner-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Worker node private IPs for Ansible inventory
  worker_private_ips = [
    module.server_node1.ipv4_address_private,
    # Add more worker nodes here as needed
  ]
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
  name = "Secure HCloud"
}

# Worker nodes (must be declared first to get their private IPs)
module "server_node1" {
  source = "../modules/server"

  name        = "${var.server_name}-worker-${var.environment}-${var.location}"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = var.ssh_keys
  user_data   = file("${path.module}/cloud-init-worker.yml")

  placement_group_id = data.hcloud_placement_group.placement_group_1.id
  network_id         = data.hcloud_network.hvpc_1.id
  firewall_ids       = []  # Managed centrally below

  labels = local.common_tags
}

# Control plane server with templated cloud-init (includes worker IPs)
module "server_lab" {
  source = "../modules/server"

  name        = "${var.server_name}-master-${var.environment}-${var.location}"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = var.ssh_keys
  user_data   = templatefile("${path.module}/cloud-init-control-plane.yml", {
    worker_ips      = join("\n", local.worker_private_ips)
    ssh_private_key = indent(6, var.ssh_private_key)
  })

  placement_group_id = data.hcloud_placement_group.placement_group_1.id
  network_id         = data.hcloud_network.hvpc_1.id
  firewall_ids       = []  # Managed centrally below

  labels = local.common_tags
  
  # Control plane depends on workers to get their private IPs
  depends_on = [module.server_node1]
}

# Centralized firewall attachment for all K8s cluster servers
resource "hcloud_firewall_attachment" "k8s_cluster" {
  firewall_id = data.hcloud_firewall.k8s_lab.id
  server_ids  = [
    module.server_lab.server_id,
    module.server_node1.server_id,
  ]
}

# Add more resources here as the project grows