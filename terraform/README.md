# Terraform Infrastructure Configuration

This directory contains the Terraform configuration files for provisioning Google Cloud infrastructure needed to complete **Kubernetes The Hard Way**.

## 📁 Directory Structure

```
terraform/
├── main.tf                    # Root module configuration
├── providers.tf               # Provider and backend configuration
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output value definitions
├── terraform.tfvars           # Variable values (sensitive - not in git)
├── terraform.tfvars.example   # Example variable configuration
├── machines.txt               # Machine database for K8s setup
├── credentials/               # Service account keys (gitignored)
├── modules/
│   ├── gce-instance/         # Compute Engine instance module
│   └── gce-network/          # VPC and firewall module
└── .terraform/               # Terraform working directory
```

## 🚀 Quick Start

### 1. Configure Variables
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your project details
vim terraform.tfvars
```

### 2. Initialize and Deploy
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Get Instance Information
```bash
# View all outputs
terraform output

# Get specific instance IPs
terraform output vm_ips
```

## 📋 Key Files

- **`main.tf`** - Orchestrates all modules and resources
- **`variables.tf`** - Defines all configurable parameters
- **`terraform.tfvars`** - Your specific configuration values
- **`machines.txt`** - Generated machine database for Kubernetes setup
- **`modules/`** - Reusable Terraform modules for GCE instances and networking

## 🔧 Module Overview

### GCE Instance Module (`modules/gce-instance/`)
- Creates Compute Engine instances with static IPs
- Configures SSH access and metadata
- Handles disk and network attachment

### GCE Network Module (`modules/gce-network/`)
- Creates custom VPC network
- Configures firewall rules for Kubernetes components
- Sets up network tags and security policies

## 🧹 Cleanup

To destroy all provisioned resources:
```bash
terraform destroy
```

## 📚 Related Documentation

- [Main Project README](../README.md) - Complete setup guide
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Original tutorial
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Provider documentation

---

**Note:** This Terraform configuration is specifically designed to align with the infrastructure requirements of Kubernetes The Hard Way tutorial.
