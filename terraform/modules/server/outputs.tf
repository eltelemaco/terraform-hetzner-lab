output "server_id" {
  description = "ID of the created server"
  value       = hcloud_server.this.id
}

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.this.name
}

output "ipv4_address" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.this.ipv4_address
}

output "ipv4_address_private" {
  description = "Private IPv4 address of the server in the network"
  value       = length(hcloud_server_network.this) > 0 ? hcloud_server_network.this[0].ip : null
}

output "ipv6_address" {
  description = "IPv6 address of the server"
  value       = hcloud_server.this.ipv6_address
}

output "private_networks" {
  description = "Private networks attached to the server"
  value       = hcloud_server_network.this
}