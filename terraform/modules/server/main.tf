resource "hcloud_server" "this" {
  name               = var.name
  server_type        = var.server_type
  image              = var.image
  location           = var.location
  ssh_keys           = var.ssh_keys
  user_data          = var.user_data
  labels             = var.labels
  placement_group_id = var.placement_group_id

  lifecycle {
    ignore_changes = [
      user_data, # Ignore changes to user_data after initial creation
    ]
  }
}

# resource "hcloud_ssh_key" "this" {
#   name       = "Hetzner-Key-${var.name}"
#   public_key = file(var.ssh_pub_key)
# }

resource "hcloud_server_network" "this" {
  count      = var.network_id != null ? 1 : 0
  server_id  = hcloud_server.this.id
  network_id = var.network_id
}

resource "hcloud_firewall_attachment" "this" {
  for_each    = toset(var.firewall_ids)
  server_ids  = [hcloud_server.this.id]
  firewall_id = each.value
}