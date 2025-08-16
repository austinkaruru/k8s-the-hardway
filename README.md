# Kubernetes The Hard Way - Automated Infrastructure

This repository automates the provisioning of Google Cloud infrastructure needed to complete [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) by Kelsey Hightower. The setup is designed to align with the manual instructions in the original guide, using **Terraform** to streamline infrastructure creation while preserving the educational value of manually configuring Kubernetes components.

## 🗂️ Project Structure

```
k8s-the-hardway/
├── terraform/          # Infrastructure as Code configuration
│   ├── main.tf        # Root Terraform module
│   ├── modules/       # Reusable GCE and network modules
│   └── README.md      # Detailed Terraform setup guide
├── k8s-thw-docs/      # MkDocs blog/documentation site
│   ├── docs/          # Markdown content
│   ├── mkdocs.yml     # Site configuration
│   └── README.md      # Documentation setup guide
└── README.md          # This overview file
```

## 🚀 Quick Start

1. **Setup Infrastructure** - Navigate to [`terraform/`](./terraform/) for detailed provisioning instructions
2. **Follow Tutorial** - Complete [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) using your provisioned infrastructure
3. **Document Journey** - Use [`k8s-thw-docs/`](./k8s-thw-docs/) to blog about your learning experience

## 📚 Documentation & Setup Guides

### Infrastructure Setup
- **[Terraform Configuration](./terraform/)** - Complete infrastructure provisioning guide
  - Prerequisites and Google Cloud setup
  - Terraform configuration and deployment
  - Post-deployment setup for Kubernetes tutorial

### Documentation Site
- **[MkDocs Blog Setup](./k8s-thw-docs/)** - Documentation and blogging platform
  - Development environment setup
  - Content creation and site building
  - Deployment options

---

## ☁️ Google Compute Engine Specifications

| Name    | Description          | vCPU | RAM | Disk | Machine Type | Purpose                                                        |
|---------|----------------------|------|-----|------|--------------|----------------------------------------------------------------|
| jumpbox | Admin access gateway | 1    | 1GB | 10GB | `e2-small`   | SSH bastion and kubectl access                                |
| server  | Control Plane Node   | 2    | 2GB | 20GB | `e2-small`   | etcd, kube-apiserver, kube-controller-manager, kube-scheduler |
| node-0  | Worker Node 1        | 2    | 2GB | 20GB | `e2-small`   | kubelet, kube-proxy, containerd                               |
| node-1  | Worker Node 2        | 2    | 2GB | 20GB | `e2-small`   | kubelet, kube-proxy, containerd                               |

> 💡 **Note:** Machine types updated to `e2-small` for better performance during Kubernetes installation and to handle compilation tasks required in the challenge.

> 🔐 Each instance has a static external IP and is accessible via SSH key authentication.

---

## 🔥 Network & Security Overview

### Firewall Rules
- **SSH (22)**: Administrative access to all instances
- **HTTP/HTTPS (80/443)**: Web traffic for testing applications
- **Kubernetes API (6443)**: Control plane API access
- **etcd (2379-2380)**: etcd client and peer communication
- **Kubelet API (10250)**: Kubelet API for kubectl logs/exec
- **NodePort Services (30000-32767)**: Kubernetes NodePort range

### Network Architecture
- Custom VPC with automatic subnet creation
- Static IP addresses for predictable access
- Network tags for targeted firewall rules

> 🔐 **Security Note**: Default configuration allows access from anywhere (`0.0.0.0/0`). See [terraform setup guide](./terraform/) for production security recommendations.

---

## 🧹 Cleanup

To destroy all provisioned resources:
```bash
cd terraform/
terraform destroy
```

> 💰 **Cost Note**: Remember to destroy resources when not in use to avoid unnecessary GCP charges.

---

## 🐛 Need Help?

- **Infrastructure Issues**: Check the [Terraform README](./terraform/) for detailed troubleshooting
- **Documentation Setup**: See the [MkDocs README](./k8s-thw-docs/) for blog setup help
- **Tutorial Questions**: Refer to the original [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) guide

---

**Happy Learning! 🎓**

This infrastructure setup provides a solid foundation for completing Kubernetes The Hard Way. The automated provisioning saves time on infrastructure setup, allowing you to focus on learning Kubernetes concepts and components.