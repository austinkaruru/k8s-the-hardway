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

## 🚀 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- SSH key pair for instance access

### Google Cloud Setup

#### Project Setup Options

**Option 1: Create a New Project (Recommended for beginners)**
```bash
# Set your project ID (make it unique!)
export PROJECT_ID="k8s-thw-$(whoami)-$(date +%Y%m%d)"

# Create the project
gcloud projects create $PROJECT_ID --name="Kubernetes The Hard Way"
gcloud config set project $PROJECT_ID

# Enable billing in the GCP Console for this project
echo "Enable billing for project: $PROJECT_ID"
```

**Option 2: Use an Existing Project**
```bash
# List your existing projects
gcloud projects list

# Set your existing project ID
export PROJECT_ID="your-existing-project-id"
gcloud config set project $PROJECT_ID

# Verify you're using the right project
gcloud config get-value project
```

> **Note:** If using an existing project, ensure it doesn't contain any production resources and has sufficient quotas available.

#### Enable Required APIs
```bash
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled --filter="name:(compute.googleapis.com OR iam.googleapis.com)"
```

#### Create Service Account
```bash
gcloud iam service-accounts create k8s-tf \
    --description="Terraform service account for Kubernetes The Hard Way" \
    --display-name="K8s Terraform SA"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:k8s-tf@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:k8s-tf@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"
```

#### Download Service Account Key
```bash
gcloud iam service-accounts keys create credentials/k8s-tf.json \
    --iam-account=k8s-tf@$PROJECT_ID.iam.gserviceaccount.com
```

#### Create GCS Bucket for Terraform State

Before running Terraform, you need to create a GCS bucket to store the Terraform state:

```bash
# Create a bucket for Terraform state (make the name globally unique)
export TF_STATE_BUCKET="kthw-tf-state-$(whoami)-$(date +%Y%m%d)"

# Create the bucket
gsutil mb gs://$TF_STATE_BUCKET

# Enable versioning for state file backup
gsutil versioning set on gs://$TF_STATE_BUCKET

# Verify bucket creation
gsutil ls gs://$TF_STATE_BUCKET
```

#### Update Backend Configuration

Update the backend configuration in `providers.tf` with your bucket name:

```hcl
terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "6.47.0"
        }
    }
    backend "gcs" {
        bucket  = "your-bucket-name-here"  # Replace with your bucket name
        prefix  = "terraform/state"
    }
}
```

#### Verify Setup
```bash
# Check current project
gcloud config get-value project

# Verify service account exists
gcloud iam service-accounts list --filter="email:k8s-tf@*"

# Check key file was created
ls -la credentials/k8s-tf.json
```

### SSH Key Setup

Generate SSH key pair if you don't have one:
```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/k8s-thw
```

## ⚙️ Configuration

### 1. Configure Variables
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your project details
vim terraform.tfvars
```

### 2. Update terraform.tfvars
```hcl
# Use the PROJECT_ID from your setup above
project_id   = "your-project-id-here"  # Replace with: echo $PROJECT_ID
vpc_name     = "k8s-thw-vpc"
ssh_key      = "~/.ssh/k8s-thw.pub"  # Path to your SSH public key
ssh_username = "your-username"
sa_account   = "k8s-tf"
boot_disk    = "pd-balanced"
gce_tags     = ["k8s-thw"]

# VM Configuration
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
  node-0 = {
    name         = "node-0"
    machine_type = "e2-small"
    disk_size_gb = 20
  }
  node-1 = {
    name         = "node-1"
    machine_type = "e2-small"
    disk_size_gb = 20
  }
}

# Network Security
google_credentials     = "credentials/k8s-tf.json"
firewall_ports        = ["22", "80", "443", "6443", "2379-2380", "10250", "30000-32767"]
firewall_protocols    = "tcp"
firewall_target_tags  = ["k8s-thw"]
firewall_source_ranges = ["0.0.0.0/0"]  # ⚠️ Restrict this in production!
```

> 🔐 **Security Note**: The default `firewall_source_ranges = ["0.0.0.0/0"]` allows access from anywhere. For production use, restrict to your IP: `["YOUR_IP/32"]`

## 🏗️ Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Plan Infrastructure
```bash
terraform plan
```

### 3. Deploy Resources
```bash
terraform apply
```

### 4. Get Instance Information
```bash
# View all outputs
terraform output

# Get specific instance IPs
terraform output vm_ips
```

## 🔧 Post-Deployment Setup

After successful deployment, prepare for the Kubernetes tutorial:

### 1. Create machines.txt File
Create a `machines.txt` file with your instance IPs (get from `terraform output`):
```bash
# Format: IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
34.90.50.182 server.kubernetes.local server
34.13.164.225 node-0.kubernetes.local node-0 10.200.0.0/24
34.32.227.137 node-1.kubernetes.local node-1 10.200.1.0/24
```

### 2. Setup SSH Access from Jumpbox
```bash
# Copy your private SSH key to jumpbox (from your local machine)
scp ~/.ssh/k8s-thw root@JUMPBOX_IP:/root/.ssh/
scp ~/.ssh/k8s-thw.pub root@JUMPBOX_IP:/root/.ssh/

# SSH to jumpbox
ssh root@JUMPBOX_IP

# Set correct permissions on jumpbox
chmod 600 /root/.ssh/k8s-thw
chmod 644 /root/.ssh/k8s-thw.pub

# Test SSH access to cluster machines
ssh -i /root/.ssh/k8s-thw root@SERVER_IP
ssh -i /root/.ssh/k8s-thw root@NODE_0_IP
ssh -i /root/.ssh/k8s-thw root@NODE_1_IP
```

### 3. Verify Setup
```bash
# Copy machines.txt to jumpbox
scp machines.txt root@JUMPBOX_IP:~/

# SSH to jumpbox and verify access to all machines
ssh root@JUMPBOX_IP

# Test connectivity to all machines
while read IP FQDN HOST SUBNET; do
  ssh -n -i /root/.ssh/k8s-thw root@${IP} hostname
done < machines.txt
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

## 🐛 Troubleshooting

### Common Issues
- **SSH Connection Refused**: Wait 2-3 minutes after deployment for instances to fully boot
- **Permission Denied on SSH**: Ensure you've copied your private key to jumpbox as described above
- **Terraform State Lock**: Use `terraform force-unlock LOCK_ID` if needed
- **API Not Enabled**: Ensure all required APIs are enabled in your GCP project

### SSH Troubleshooting
```bash
# Test SSH with verbose output
ssh -v -i ~/.ssh/k8s-thw root@instance-ip

# Check SSH service status on target machine
systemctl status sshd

# View SSH configuration
cat /etc/ssh/sshd_config | grep -E "(PermitRootLogin|PubkeyAuthentication|PasswordAuthentication)"
```

## 🧹 Cleanup

To destroy all provisioned resources:
```bash
terraform destroy
```

> 💰 **Cost Note**: Remember to destroy resources when not in use to avoid unnecessary GCP charges.

## 📚 Related Documentation

- [Main Project README](../README.md) - Complete setup guide
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Original tutorial
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Provider documentation

---

**Note:** This Terraform configuration is specifically designed to align with the infrastructure requirements of Kubernetes The Hard Way tutorial.
