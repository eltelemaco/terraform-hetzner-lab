# Hetzner Cloud API Token
# Obtain from: https://console.hetzner.cloud/projects/[project-id]/access/tokens
# hcloud_token = "your-hetzner-api-token-here"
# the actual token value is set via environment variable or secret management for security

# Server Configuration
server_name = "labserver"
location    = "hil" # Hillsboro, US West
server_type = "cpx21"
environment = "dev"
image       = "ubuntu-22.04"


# SSH Keys (names as they appear in Hetzner console)
ssh_keys = ["Secure HCloud"]

# Note: Replace 'your-hetzner-api-token-here' with your actual 64-character API token
# This file is ignored by git for security