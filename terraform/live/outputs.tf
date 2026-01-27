# Outputs for important resource attributes
output "server_lab_name" {
  description = "Name of the server-lab server"
  value       = module.server_lab.server_name
}

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

output "server_lab_ipv4_address_private" {
  description = "Private IPv4 address of the server-lab server"
  value       = module.server_lab.ipv4_address_private
}
output "server_node1_name" {
  description = "Name of the server-node1 server"
  value       = module.server_node1.server_name
}

output "server_node1_id" {
  description = "ID of the server-node1 server"
  value       = module.server_node1.server_id
}
output "server_node1_ipv4_address" {
  description = "IPv4 address of the server-node1 server"
  value       = module.server_node1.ipv4_address
}

output "server_node1_ipv4_address_private" {
  description = "Private IPv4 address of the server-node1 server"
  value       = module.server_node1.ipv4_address_private
}

# Ansible provisioning helper outputs
output "ssh_command_control_plane" {
  description = "SSH command to connect to control plane"
  value       = "ssh -i ~/.ssh/hcloud telemaco@${module.server_lab.ipv4_address}"
}

output "ansible_status_command" {
  description = "Command to check Ansible provisioning status"
  value       = "ssh -i ~/.ssh/hcloud telemaco@${module.server_lab.ipv4_address} 'sudo k3s-status'"
}

output "ansible_logs_command" {
  description = "Command to view Ansible logs"
  value       = "ssh -i ~/.ssh/hcloud telemaco@${module.server_lab.ipv4_address} 'sudo tail -f /opt/ansible/logs/ansible.log'"
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes for Ansible inventory"
  value       = local.worker_private_ips
}