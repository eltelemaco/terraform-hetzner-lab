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
| [Quick Start](docs/QUICK_START.md) | Get started quickly with either deployment method |
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
