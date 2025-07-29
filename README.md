# Kubernetes The Hard Way Provisioning via Terraform (Google Cloud)

This repository automates the provisioning of Google Cloud infrastructure needed to complete [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) by Kelsey Hightower. The setup is designed to align with the manual instructions in the original guide, using **Terraform** to streamline and manage infrastructure creation.

## 📦 What This Terraform Setup Does

- Creates a custom **VPC network** and a firewall with required port access
- Provisions multiple **Google Compute Engine (GCE)** instances for control plane and worker nodes
- Automatically injects an SSH public key for secure access
- Uses **Terraform modules** and **for_each** to dynamically create and manage resources

---

## ☁️ Google Compute Engine Specifications

| Name    | Description          | vCPU | RAM    | Disk  | Machine Type |
|---------|----------------------|------|--------|-------|--------------|
| jumpbox | Admin access gateway | 1    | 512MB  | 10GB  | `e2-micro`   |
| server  | Control Plane Node   | 2    | 2GB    | 20GB  | `e2-small`   |
| node-0  | Worker Node 1        | 2    | 4GB    | 20GB  | `e2-medium`  |
| node-1  | Worker Node 2        | 2    | 4GB    | 20GB  | `e2-medium`  |

> 🔐 Each instance will have an external IP and be accessible via the specified SSH key.

---

## 📁 Project Structure

```bash
.
├── main.tf                  # Core infrastructure setup
├── variables.tf             # Input variables (VM specs, SSH keys, etc.)
├── outputs.tf               # Useful outputs like IPs and instance names
├── modules/
│   └── gce/                 # Reusable VM creation module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── terraform.tfvars         # (Optional) values for input variables
└── README.md                # You're here!
