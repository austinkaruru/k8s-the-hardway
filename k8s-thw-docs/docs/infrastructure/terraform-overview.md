# Terraform Overview: Infrastructure as Code for K8s

Now we get to the fun part - using Terraform to automate all the infrastructure setup that would normally take forever to do manually in the GCP console!

## Why Terraform for This Project?

### The Manual Alternative
Without Terraform, setting up the infrastructure would involve:

- Clicking through the GCP console to create a VPC
- Manually configuring firewall rules (and probably forgetting some)
- Creating 4 VM instances one by one
- Setting up static IP addresses
- Configuring SSH access for each machine
- Hoping you didn't miss anything...

### The Terraform Way
With Infrastructure as Code:

- Everything is defined in version-controlled files
- Reproducible deployments every time
- Easy to tear down and rebuild if something goes wrong
- Self-documenting infrastructure

!!! tip "Learning Opportunity"
    Even if you're new to Terraform, this project is a great way to learn IaC concepts with a real-world example.

## Project Structure

Here's how I've organized the Terraform code:

```
terraform/
├── main.tf                    # Root module - orchestrates everything
├── providers.tf               # Provider configuration and versions
├── variables.tf               # Input variable definitions
├── outputs.tf                 # What we want to know after deployment
├── terraform.tfvars           # Your specific configuration values
├── terraform.tfvars.example   # Template for configuration
├── modules/
│   ├── gce-instance/         # Reusable VM creation module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── gce-network/          # Network and firewall module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── credentials/              # Service account keys (gitignored)
```

## Module Design Philosophy

### GCE Instance Module
This module handles everything related to creating VM instances:

- Compute Engine instances with proper sizing
- Static IP address allocation
- SSH key injection
- Metadata configuration
- Boot disk setup

**Why modular?** Because we're creating 4 similar-but-different VMs. The module lets us define the pattern once and reuse it.

### GCE Network Module
This module sets up all the networking:

- Custom VPC network
- Firewall rules for all Kubernetes components
- Network tags for security targeting

**Why separate?** Network setup is foundational - it needs to exist before we can create instances.

## State Management Strategy

### Remote State with GCS Backend
Instead of storing Terraform state locally, we use Google Cloud Storage:

```hcl
backend "gcs" {
    bucket  = "kthw-tf-state"
    prefix  = "terraform/state"
}
```

**Benefits:**

- **Collaboration**: Multiple team members can work on the same infrastructure
- **State Locking**: Prevents concurrent modifications that could corrupt state
- **Backup & Versioning**: GCS versioning protects against state file loss
- **Security**: State file is encrypted at rest in GCS

### State File Contents
The state file contains:

- Current resource configurations
- Resource dependencies
- Metadata about your infrastructure
- Sensitive information (passwords, keys, etc.)

!!! warning "State File Security"
    Never commit state files to version control! They contain sensitive information and should be stored securely in the GCS backend.

## Infrastructure Components

### Virtual Private Cloud (VPC)
```hcl
# Custom VPC with automatic subnets
resource "google_compute_network" "k8s_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = true
  routing_mode           = "REGIONAL"
}
```

### Firewall Rules
We need specific ports open for Kubernetes to work:

| Port Range | Purpose | Component |
|------------|---------|-----------|
| 22 | SSH access | All nodes |
| 80, 443 | HTTP/HTTPS | Testing web apps |
| 6443 | Kubernetes API | Control plane |
| 2379-2380 | etcd | Control plane |
| 10250 | Kubelet API | All nodes |
| 30000-32767 | NodePort services | Worker nodes |

### Compute Instances
Each instance gets:

- **Static external IP** for consistent access
- **e2-small machine type** (2 vCPU, 2GB RAM)
- **Ubuntu 20.04 LTS** as the base OS
- **SSH key injection** for passwordless access
- **Root access enabled** (required for the tutorial)

## Configuration Strategy

### Using terraform.tfvars
Instead of hardcoding values, everything is configurable:

```hcl
# Your project-specific values
project_id   = "k8s-thw-yourname-20240816"
vpc_name     = "k8s-thw-vpc"
ssh_key      = "~/.ssh/id_ed25519.pub"
ssh_username = "yourname"

# VM definitions
vms = {
  jumpbox = {
    name         = "jumpbox"
    machine_type = "e2-small"
    disk_size_gb = 10
  }
  server = {
    name         = "server"
    machine_type = "e2-small"
    disk_size_gb = 20
  }
  # ... more VMs
}
```

### Security Considerations
The default configuration allows access from anywhere (`0.0.0.0/0`) for simplicity. In production, you'd want to:

- Restrict source IP ranges to your location
- Use more granular firewall rules
- Implement proper bastion host patterns
- Use service accounts with minimal permissions

!!! warning "Lab vs Production"
    This setup prioritizes learning and convenience over production security practices.

## What Terraform Will Create

When you run `terraform apply`, you'll get:

1. **1 Custom VPC** with automatic subnets
2. **4 Static IP addresses** for predictable access
3. **4 VM instances** ready for Kubernetes installation
4. **Comprehensive firewall rules** for all K8s components
5. **SSH access configured** for the tutorial workflow

## Cost Breakdown

Here's what you'll be paying for:

| Resource | Quantity | Cost/Hour (approx) |
|----------|----------|-------------------|
| e2-small instances | 4 | $0.20 |
| Static IP addresses | 4 | $0.02 |
| Network egress | Minimal | $0.01 |
| **Total** | | **~$0.23/hour** |

!!! tip "Cost Control"
    Remember to run `terraform destroy` when you're done to avoid ongoing charges!

## Next Steps

Ready to deploy? Let's move on to the [deployment process](terraform-deployment.md) where we'll actually create this infrastructure!

The beauty of Terraform is that once it's configured, deployment is just a few commands away.

---

!!! info "Terraform Learning Resources"
    New to Terraform? Check out the [official tutorials](https://learn.hashicorp.com/terraform) - they're excellent!
