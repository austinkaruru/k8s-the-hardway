# Kubernetes The Hard Way Provisioning via Terraform (Google Cloud)

This repository automates the provisioning of Google Cloud infrastructure needed to complete [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) by Kelsey Hightower. The setup is designed to align with the manual instructions in the original guide, using **Terraform** to streamline and manage infrastructure creation.

## 📦 What This Terraform Setup Does

- Creates a custom **VPC network** with firewall rules for Kubernetes components
- Provisions multiple **Google Compute Engine (GCE)** instances for control plane and worker nodes
- Automatically configures static IP addresses for consistent access
- Injects SSH public key for secure access to all instances
- Uses **Terraform modules** and **for_each** for scalable infrastructure management

---

## ☁️ Google Compute Engine Specifications

| Name    | Description          | vCPU | RAM    | Disk  | Machine Type | Purpose |
|---------|----------------------|------|--------|-------|--------------|---------|
| jumpbox | Admin access gateway | 1    | 1GB    | 10GB  | `e2-small`   | SSH bastion and kubectl access |
| server  | Control Plane Node   | 2    | 2GB    | 20GB  | `e2-small`   | etcd, kube-apiserver, kube-controller-manager, kube-scheduler |
| node-0  | Worker Node 1        | 2    | 2GB    | 20GB  | `e2-small`   | kubelet, kube-proxy, containerd |
| node-1  | Worker Node 2        | 2    | 2GB    | 20GB  | `e2-small`   | kubelet, kube-proxy, containerd |

> 💡 **Note:** Machine types updated to `e2-small` for better performance during Kubernetes installation and to handle compilation tasks required in the challenge.

> 🔐 Each instance has a static external IP and is accessible via SSH key authentication.

---

## 🔥 Network & Security Configuration

### Firewall Rules
- **SSH (22)**: Administrative access to all instances
- **HTTP (80)**: For testing web applications
- **HTTPS (443)**: Secure web traffic
- **Kubernetes API (6443)**: Control plane API access
- **etcd (2379-2380)**: etcd client and peer communication
- **Kubelet API (10250)**: Kubelet API for kubectl logs/exec
- **NodePort Services (30000-32767)**: Kubernetes NodePort range

### Network Architecture
- Custom VPC with automatic subnet creation
- Static IP addresses for predictable access
- Network tags for targeted firewall rules

---

## 📁 Project Structure

```bash
.
├── main.tf                 # Root module and provider configuration
├── variables.tf            # Input variables definition
├── outputs.tf             # Output values (IPs, instance names)
├── terraform.tfvars       # Variable values (sensitive data)
├── modules/
│   ├── gce/               # Compute Engine module
│   │   ├── main.tf        # VM, disk, and IP resources
│   │   ├── variables.tf   # Module input variables
│   │   └── outputs.tf     # Module outputs
│   └── net/               # Network module
│       ├── main.tf        # VPC and firewall resources
│       ├── variables.tf   # Network variables
│       └── outputs.tf     # Network outputs
├── credentials/           # Service account keys (gitignored)
└── README.md
```

---

## 🚀 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- SSH key pair for instance access

### Google Cloud Setup
1. **Create a GCP Project**
   ```bash
   gcloud projects create YOUR_PROJECT_ID
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

3. **Create Service Account**
   ```bash
   gcloud iam service-accounts create k8s-tf \
       --description="Terraform service account for Kubernetes The Hard Way" \
       --display-name="K8s Terraform SA"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
       --member="serviceAccount:k8s-tf@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/compute.admin"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
       --member="serviceAccount:k8s-tf@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/iam.serviceAccountUser"
   ```

4. **Download Service Account Key**
   ```bash
   gcloud iam service-accounts keys create credentials/k8s-tf.json \
       --iam-account=k8s-tf@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

---

## ⚙️ Configuration

### 1. Update terraform.tfvars
```hcl
project_id   = "your-project-id-here"
vpc_name     = "name-of-your-vpc"
ssh_key      = "~/.ssh/id_rsa.pub"  # Path to your SSH public key
ssh_username = "your-username"
sa_account   = "your-service-account-name"
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
google_credentials     = "credentials/service-account-file.json"
firewall_ports        = ["22", "80", "443", "6443", "2379-2380", "10250", "30000-32767"]
firewall_protocols    = "tcp"
firewall_target_tags  = ["k8s-thw"]
firewall_source_ranges = ["0.0.0.0/0"]  # ⚠️ Restrict this in production!
```

### 2. Generate SSH Key (if needed)
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com" -f ~/.ssh/k8s-thw
```

---

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

### 4. Connect to Instances
```bash
# Get instance IPs
terraform output vm_ips

# SSH to jumpbox
ssh -i ~/.ssh/id_rsa username@JUMPBOX_IP

# SSH to other instances via jumpbox (recommended)
ssh -i ~/.ssh/id_rsa -J username@JUMPBOX_IP username@SERVER_IP
```

---

## 🔧 Post-Deployment

After successful deployment, you'll have:
- ✅ 4 Ubuntu instances with static IPs
- ✅ Properly configured networking and firewall rules
- ✅ SSH access configured for all instances
- ✅ Ready environment for Kubernetes The Hard Way installation

### Next Steps
1. Follow the [Kubernetes The Hard Way guide](https://github.com/kelseyhightower/kubernetes-the-hard-way) starting from **"Installing the Client Tools"**
2. Use the jumpbox as your admin workstation
3. The server instance will host your control plane
4. node-0 and node-1 will be your worker nodes

---

## 🔒 Security Considerations

⚠️ **Important Security Notes:**
- The default firewall allows access from `0.0.0.0/0` - restrict this to your IP range in production
- SSH keys are added at the project level - consider instance-level keys for better isolation
- All instances have external IPs - use internal-only IPs with a bastion host for production workloads

### Recommended Security Improvements
```hcl
# Restrict firewall to your IP
firewall_source_ranges = ["YOUR_IP/32"]

# Use more specific port ranges
firewall_ports = ["22"]  # Only SSH, add others as needed
```

---

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

> 💰 **Cost Note:** Remember to destroy resources when not in use to avoid unnecessary GCP charges.

---

## 🐛 Troubleshooting

### Common Issues
- **SSH Connection Refused**: Wait 2-3 minutes after deployment for instances to fully boot
- **Permission Denied**: Ensure your service account has proper IAM roles
- **Terraform State Lock**: Use `terraform force-unlock LOCK_ID` if needed

### Useful Commands
```bash
# Check instance status
gcloud compute instances list

# View firewall rules
gcloud compute firewall-rules list

# SSH with verbose output
ssh -v -i ~/.ssh/id_rsa username@instance-ip
```

---

## 📚 Additional Resources

- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Original guide
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Documentation
- [Google Cloud Free Tier](https://cloud.google.com/free) - Cost optimization

---

**Happy Learning! 🎓**

This infrastructure setup provides a solid foundation for completing Kubernetes The Hard Way. The automated provisioning saves time on infrastructure setup, allowing you to focus on learning Kubernetes concepts and components.