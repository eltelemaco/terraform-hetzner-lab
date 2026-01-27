# Terraform Hetzner Lab

> A complete Infrastructure as Code (IaC) solution for deploying a K3s Kubernetes cluster on Hetzner Cloud using Terraform and Ansible.

![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple?style=flat-square&logo=terraform)
![Hetzner Cloud](https://img.shields.io/badge/Hetzner%20Cloud-Provider-red?style=flat-square)
![K3s](https://img.shields.io/badge/K3s-Kubernetes-326CE5?style=flat-square&logo=kubernetes)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=flat-square&logo=ansible)
![License](https://img.shields.io/badge/License-Open%20Source-green?style=flat-square)

---

## 📋 Overview

This repository provides an automated infrastructure deployment solution for creating a lightweight Kubernetes cluster on Hetzner Cloud. It leverages **Terraform** for infrastructure provisioning and **Ansible** for cluster configuration, deploying a fully functional **K3s** control plane with worker nodes.

### Key Features

- 🏗️ **Infrastructure as Code** - Complete cloud infrastructure defined in Terraform
- ☸️ **K3s Kubernetes** - Lightweight, production-ready Kubernetes distribution
- 🔄 **Dual Deployment Options** - Choose between pure Terraform or Ansible-based provisioning
- 🔐 **Security First** - Firewall rules, SSH key authentication, and private networking
- 📦 **Modular Design** - Reusable Terraform modules for server provisioning
- ☁️ **Cloud-Init Integration** - Automated server bootstrapping with cloud-init
- 🌐 **HCP Terraform Backend** - Remote state management via HashiCorp Cloud Platform

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Hetzner Cloud                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC Network                       │   │
│  │  ┌─────────────┐         ┌─────────────────────┐    │   │
│  │  │ Control     │         │    Worker Node(s)   │    │   │
│  │  │ Plane       │◄───────►│                     │    │   │
│  │  │ (K3s Server)│  K3s    │    (K3s Agent)      │    │   │
│  │  │             │ Cluster │                     │    │   │
│  │  └─────────────┘         └─────────────────────┘    │   │
│  │                                                      │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │             Placement Group                     │ │   │
│  │  │             Firewall (k8s-lab)                  │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
├── terraform/
│   ├── live/                    # Live environment configuration
│   │   ├── main.tf              # Main infrastructure definition
│   │   ├── variables.tf         # Input variables
│   │   ├── outputs.tf           # Output values
│   │   ├── providers.tf         # Provider configuration
│   │   ├── backend.tf           # HCP Terraform backend config
│   │   ├── dev.auto.tfvars      # Development environment variables
│   │   ├── cloud-init-control-plane.yml  # Control plane bootstrap
│   │   ├── cloud-init-worker.yml         # Worker node bootstrap
│   │   └── cloud-init.yml       # Base cloud-init template
│   │
│   └── modules/
│       └── server/              # Reusable server module
│           ├── main.tf          # Server resource definition
│           ├── variables.tf     # Module input variables
│           ├── outputs.tf       # Module outputs
│           └── providers.tf     # Provider requirements
│
├── ansible/
│   ├── ansible.cfg              # Ansible configuration
│   ├── inventory.tpl            # Dynamic inventory template
│   ├── k3s-cluster.yml          # K3s deployment playbook
│   └── roles/                   # Ansible roles
│
├── docs/
│   ├── QUICK_START.md           # Quick start guide
│   ├── DEPLOYMENT_COMPARISON.md # Comparison of deployment methods
│   ├── HCP_TERRAFORM_SETUP.md   # HCP Terraform setup guide
│   ├── ANSIBLE_CONTROL_PLANE_DEPLOYMENT_PLAN.md
│   ├── SECURITY_INCIDENT_RESPONSE.md
│   └── cloud-init-*.yml         # Cloud-init examples
│
├── .github/                     # GitHub workflows and templates
├── .gitignore                   # Git ignore rules
└── LICENSE                      # Open source license
```

---

## 💻 Source Code Description

### Terraform Live Configuration (`terraform/live/`)

#### Core Infrastructure Files

**main.tf** (86 lines)
- **Purpose**: Main infrastructure orchestration file that provisions the complete K3s cluster
- **Key Components**:
  - Declares control plane and worker node servers using the reusable `server` module
  - Manages data sources for existing Hetzner resources (network, placement groups, firewall, SSH keys)
  - Implements local variables for computed values (naming conventions, worker IPs)
  - Templates cloud-init configurations with dynamic worker IP injection for Ansible inventory
  - Centralizes firewall attachment management for all cluster servers
- **Resources**: hcloud_server_network, hcloud_firewall_attachment
- **Data Sources**: hcloud_network, hcloud_placement_group, hcloud_firewall, hcloud_ssh_keys

**variables.tf** (78 lines)
- **Purpose**: Input variable definitions with validation and security controls
- **Variables Defined**:
  - `hcloud_token`: Hetzner Cloud API authentication (sensitive)
  - `location`: Datacenter location with validation (hel1, fsn1, nbg1, ash, hil)
  - `server_type`: Instance type (default: cpx21)
  - `server_name`: Base server naming
  - `image`: OS image (default: ubuntu-22.04)
  - `ssh_keys`: SSH key identifiers list
  - `environment`: Environment classification (dev/staging/prod)
  - `ssh_private_key`: SSH private key for Ansible connections (sensitive, stored in HCP Terraform)
- **Features**: Variable validation, sensitive data protection, documented defaults

**outputs.tf** (64 lines)
- **Purpose**: Exports infrastructure attributes for external consumption and user interaction
- **Key Outputs**:
  - Server identifiers (names, IDs)
  - Public and private IPv4/IPv6 addresses for control plane and workers
  - SSH connection commands (formatted for direct CLI usage)
  - Ansible status monitoring commands
  - Worker node private IPs list (used for inventory generation)
- **Usage**: Enables seamless cluster access and monitoring without manual IP lookup

**providers.tf** (13 lines)
- **Purpose**: Provider configuration and version pinning
- **Configuration**: Hetzner Cloud provider (~> 1.56.0) with API token authentication
- **Requirements**: Terraform >= 1.5

**backend.tf** (18 lines)
- **Purpose**: Remote state management configuration
- **Backend**: HCP Terraform (HashiCorp Cloud Platform)
- **Organization**: TelemacoInfraLabs
- **Workspace**: terraform-hetzner-lab
- **Benefits**: Centralized state storage, team collaboration, state encryption

### Terraform Server Module (`terraform/modules/server/`)

#### Reusable Server Module

**main.tf** (33 lines)
- **Purpose**: Encapsulates Hetzner Cloud server provisioning logic for reusability
- **Resources**:
  - `hcloud_server`: Creates virtual machine instances with lifecycle management
  - `hcloud_server_network`: Attaches servers to private VPC network
- **Features**:
  - Lifecycle rules to ignore user_data changes (prevents recreation on cloud-init updates)
  - Dynamic firewall attachment support
  - Placement group integration for high availability
  - Cloud-init integration for automated bootstrapping

**variables.tf** (60 lines)
- **Purpose**: Module input variables for flexible server provisioning
- **Variable Categories**:
  - Server specifications (name, type, image, location)
  - Network configuration (network_id, subnet_id)
  - Security (ssh_keys, firewall_ids)
  - High availability (placement_group_id)
  - Initialization (user_data for cloud-init)
  - Metadata (labels for organization)

**outputs.tf** (29 lines)
- **Purpose**: Exports server attributes for consumption by live configuration
- **Exported Values**: Server details (id, name, status), networking (IPv4/IPv6, private IPs), network attachment information

**providers.tf** (8 lines)
- **Purpose**: Declares required provider versions for module compatibility

### Cloud-Init Bootstrap Scripts (`terraform/live/`)

#### cloud-init-control-plane.yml (372 lines)
- **Purpose**: Comprehensive server initialization script for K3s control plane nodes
- **Bootstrap Phases**:
  1. **Package Installation**: System packages (curl, wget, git, jq, fail2ban, ufw, python3, ansible), Kubernetes dependencies (conntrack, socat, ebtables, ethtool)
  2. **User Management**: Creates 'telemaco' user with sudo privileges, SSH key setup, secure home directory
  3. **SSH Hardening**: Disables password authentication, root login, limits login attempts, enables key-based auth only
  4. **Kubernetes Prerequisites**: Configures sysctl for networking (ip_forward, bridge-nf-call-iptables), increases inotify limits, disables swap
  5. **Ansible Injection**: Embeds three Ansible playbooks as systemd service:
     - `self-configure.yml`: Installs K3s server (control plane)
     - `configure-workers.yml`: Connects worker nodes to cluster
     - `post-config.yml`: Labels nodes and removes cloud provider taints
  6. **Automation**: Systemd timer runs Ansible every 2 minutes (first run after 3 minutes)
  7. **Firewall Configuration**: UFW rules for K3s (ports 6443, 10250), SSH hardening
  8. **Security Services**: Enables fail2ban for DDoS/brute force protection
  9. **Monitoring Tools**: Creates `k3s-status` helper script for provisioning progress tracking
- **Key Feature**: Self-provisioning approach eliminates need for external configuration management

#### cloud-init-worker.yml (98+ lines)
- **Purpose**: Bootstrap configuration for K3s worker nodes
- **Configuration**:
  - Similar package installation and security hardening as control plane
  - Lighter configuration (no Ansible or K8s control plane dependencies)
  - SSH security hardening (identical to control plane)
  - Kubernetes prerequisites (conntrack, socat, ebtables, ethtool)
  - UFW firewall configuration for worker node security
- **Design Philosophy**: Minimal bootstrap; actual K3s agent installation handled by control plane Ansible

### Ansible Orchestration (`ansible/`)

#### k3s-cluster.yml (106 lines)
- **Purpose**: Three-phase Kubernetes cluster deployment orchestration
- **Play 1: Deploy K3s Control Plane** (runs on control_plane hosts)
  - Waits for system readiness (cloud-init completion)
  - Checks for existing K3s installation (idempotent)
  - Downloads and installs K3s server binary with Traefik disabled
  - Retrieves K3s node-token for worker registration
  - Fixes kubeconfig file ownership for non-root access
  - Labels control plane node with appropriate role
- **Play 2: Deploy K3s Workers** (runs on workers hosts)
  - Waits for system readiness
  - Installs K3s agent binary on worker nodes
  - Connects workers to control plane using token and API endpoint
  - Configures worker nodes to join the cluster
- **Play 3: Post-Installation Configuration** (runs on control_plane)
  - Waits for all nodes to report ready status
  - Removes cloud provider taints (enables scheduling)
  - Applies worker node labels for workload placement
  - Displays final cluster status with all nodes
- **Key Features**: Idempotent operations, wait conditions for reliability, modular play structure

#### ansible.cfg (12 lines)
- **Purpose**: Ansible runtime configuration for automated deployments
- **Settings**:
  - Host key checking disabled (automated environment)
  - Dynamic inventory file location
  - Default remote user and SSH private key path
  - SSH connection optimization (ControlMaster, ControlPersist)
  - Pipelining enabled for performance improvement
- **Design**: Optimized for cloud automation and CI/CD integration

#### inventory.tpl
- **Purpose**: Jinja2 template for dynamic Ansible inventory generation
- **Functionality**: Terraform populates this template with control plane and worker node IPs
- **Usage**: Creates runtime inventory file for Ansible playbook targeting

### CI/CD Automation (`.github/workflows/`)

#### terraform.yml (66 lines)
- **Purpose**: Continuous Integration and Continuous Deployment workflow for Terraform changes
- **Triggers**:
  - Push events to main and develop branches
  - Pull requests to main and develop branches
  - Path filter: Only runs when `terraform/**` files change
- **Workflow Steps**:
  1. Code checkout from repository
  2. Terraform setup (version 1.6.6)
  3. Credential configuration (Hetzner Cloud token, HCP Terraform token)
  4. Backend initialization (`terraform init` with HCP Terraform)
  5. Configuration validation (`terraform validate`)
  6. Infrastructure planning (`terraform plan`)
  7. **Conditional Auto-Apply**: Automatically applies changes on pushes to develop branch
- **Environment**: Ubuntu Latest with Terraform 1.6.6
- **Security**: Uses GitHub Secrets for sensitive credentials
- **Key Feature**: Automated deployment to development environment while requiring manual approval for production

### Documentation (`docs/`)

The project includes comprehensive documentation covering:
- **QUICK_START.md**: Step-by-step deployment guide for both Terraform and Ansible methods
- **DEPLOYMENT_COMPARISON.md**: Trade-off analysis between cloud-init and Ansible-based approaches
- **HCP_TERRAFORM_SETUP.md**: Remote state backend configuration guide
- **ANSIBLE_CONTROL_PLANE_DEPLOYMENT_PLAN.md**: Detailed Ansible deployment architecture and decision rationale
- **SECURITY_INCIDENT_RESPONSE.md**: Security procedures and incident response protocols

---

## 🚀 Getting Started

### Prerequisites

- **Terraform** >= 1.0
- **Hetzner Cloud Account** with API token
- **SSH Key** registered in Hetzner Cloud
- **Ansible** (optional, for Ansible-based provisioning)
- **HCP Terraform Account** (for remote state management)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/eltelemaco/terraform-hetzner-lab.git
   cd terraform-hetzner-lab
   ```

2. **Configure variables**
   ```bash
   cd terraform/live
   # Edit dev.auto.tfvars with your values
   ```

3. **Initialize and deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Verify deployment**
   ```bash
   ssh -i ~/.ssh/hetzner telemaco@$(terraform output -raw server_lab_ipv4_address) "sudo k3s kubectl get nodes"
   ```

For detailed instructions, see the [Quick Start Guide](docs/QUICK_START.md).

---

## ⚙️ Configuration

### Required Variables

| Variable | Description | Type |
|----------|-------------|------|
| `hcloud_token` | Hetzner Cloud API token | `string` (sensitive) |
| `ssh_private_key` | SSH private key for Ansible connections | `string` (sensitive) |
| `server_name` | Base name for servers | `string` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Hetzner datacenter location | `hil` |
| `server_type` | Server type (e.g., cpx11, cpx21) | `cpx21` |
| `image` | OS image | `ubuntu-22.04` |
| `environment` | Environment name (dev/staging/prod) | `dev` |

---

## 🔧 Terraform Modules

### Server Module

The `server` module (`terraform/modules/server`) is a reusable component for provisioning Hetzner Cloud servers with:

- **Server provisioning** with configurable type, image, and location
- **Network attachment** to private VPC networks
- **Firewall attachment** for security rules
- **Placement groups** for high availability
- **Cloud-init** for automated bootstrapping

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Quick Start](docs/QUICK_START.md) | Get started quickly with deployment |
| [Replication Template](docs/REPLICATION_TEMPLATE.md) | Complete template to replicate this project |
| [Deployment Comparison](docs/DEPLOYMENT_COMPARISON.md) | Compare pure Terraform vs Ansible approaches |
| [HCP Terraform Setup](docs/HCP_TERRAFORM_SETUP.md) | Configure HashiCorp Cloud Platform backend |
| [Ansible Deployment Plan](docs/ANSIBLE_CONTROL_PLANE_DEPLOYMENT_PLAN.md) | Detailed Ansible deployment architecture |
| [Security Incident Response](docs/SECURITY_INCIDENT_RESPONSE.md) | Security procedures and incident response |

---

## 🛡️ Security

- **SSH Key Authentication** - Password authentication disabled
- **Private Networking** - Internal communication via VPC
- **Firewall Rules** - Centralized firewall management
- **Sensitive Variables** - API tokens and keys marked as sensitive
- **Remote State** - Encrypted state storage in HCP Terraform

---

## 📤 Outputs

After deployment, the following outputs are available:

| Output | Description |
|--------|-------------|
| `server_lab_ipv4_address` | Public IPv4 of the control plane |
| `server_lab_ipv4_address_private` | Private IPv4 of the control plane |
| `server_node1_ipv4_address` | Public IPv4 of worker node |
| `ssh_command_control_plane` | SSH command to connect to control plane |
| `ansible_status_command` | Command to check K3s status |
| `worker_private_ips` | List of worker node private IPs |

---

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform/live
terraform destroy -auto-approve
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under an open source license - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Hetzner Cloud](https://www.hetzner.com/cloud) - Cloud infrastructure provider
- [K3s](https://k3s.io/) - Lightweight Kubernetes distribution
- [HashiCorp Terraform](https://www.terraform.io/) - Infrastructure as Code tool
- [Ansible](https://www.ansible.com/) - Automation platform
