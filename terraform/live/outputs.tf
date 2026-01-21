# Outputs for important resource attributes

output "server_lab_id" {
  description = "ID of the server-lab server"
  value       = module.server_lab.server_id
}

output "server_lab_ipv4_address" {
  description = "IPv4 address of the server-lab server"
  value       = module.server_lab.ipv4_address
}

output "server_lab_ipv6_address" {
  description = "IPv6 address of the server-lab server"
  value       = module.server_lab.ipv6_address
}