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
├── machines.txt           # Machine database for Kubernetes setup
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

### 4. Get Instance IPs
```bash
terraform output vm_ips
```

---

## 🔧 Post-Deployment Setup for Kubernetes The Hard Way

After successful Terraform deployment, follow these steps to prepare for the Kubernetes setup:

### 1. Create machines.txt File
Create a `machines.txt` file with your instance IPs (get from `terraform output`):
```bash
# Format: IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
34.90.50.182 server.kubernetes.local server
34.13.164.225 node-0.kubernetes.local node-0 10.200.0.0/24
34.32.227.137 node-1.kubernetes.local node-1 10.200.1.0/24
```

### 2. Setup SSH Access from Jumpbox

Since Terraform configured your VMs with your local SSH key, you need to copy that key to the jumpbox to follow the tutorial:

```bash
# Copy your private SSH key to jumpbox (from your local machine)
scp ~/.ssh/id_ed25519 root@JUMPBOX_IP:/root/.ssh/
scp ~/.ssh/id_ed25519.pub root@JUMPBOX_IP:/root/.ssh/

# SSH to jumpbox
ssh root@JUMPBOX_IP

# Set correct permissions on jumpbox
chmod 600 /root/.ssh/id_ed25519
chmod 644 /root/.ssh/id_ed25519.pub

# Test SSH access to cluster machines
ssh -i /root/.ssh/id_ed25519 root@SERVER_IP
ssh -i /root/.ssh/id_ed25519 root@NODE_0_IP
ssh -i /root/.ssh/id_ed25519 root@NODE_1_IP
```

### 3. Continue with Kubernetes The Hard Way Tutorial

Now you can follow the standard tutorial steps from the jumpbox:

```bash
# Copy machines.txt to jumpbox
scp machines.txt root@JUMPBOX_IP:~/

# SSH to jumpbox and continue with the tutorial
ssh root@JUMPBOX_IP

# Verify SSH access to all machines
while read IP FQDN HOST SUBNET; do
  ssh -n -i /root/.ssh/id_ed25519 root@${IP} hostname
done < machines.txt
```

---

## 🔒 SSH Configuration Details

The Terraform setup automatically:
- Enables root SSH access on all instances
- Configures SSH key authentication using your provided public key
- Disables password authentication for security
- Sets proper SSH daemon configuration

**Important**: The jumpbox uses the same SSH key as configured in your terraform.tfvars, so you must copy your private key to the jumpbox to access other machines as described above.

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
- **Permission Denied on SSH**: Ensure you've copied your private key to jumpbox as described above
- **Terraform State Lock**: Use `terraform force-unlock LOCK_ID` if needed

### SSH Troubleshooting
```bash
# Test SSH with verbose output
ssh -v -i ~/.ssh/id_ed25519 root@instance-ip

# Check SSH service status on target machine
systemctl status sshd

# View SSH configuration
cat /etc/ssh/sshd_config | grep -E "(PermitRootLogin|PubkeyAuthentication|PasswordAuthentication)"
```

---

## 📚 Additional Resources

- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Original guide
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Documentation
- [Google Cloud Free Tier](https://cloud.google.com/free) - Cost optimization

---

**Happy Learning! 🎓**

This infrastructure setup provides a solid foundation for completing Kubernetes The Hard Way. The automated provisioning saves time on infrastructure setup, allowing you to focus on learning Kubernetes concepts and components.