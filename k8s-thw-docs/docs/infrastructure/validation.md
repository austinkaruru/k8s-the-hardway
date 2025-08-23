# Infrastructure Validation: Making Sure Everything Works

Before we dive into Kubernetes installation, let's thoroughly test our infrastructure to catch any issues early. Trust me, it's much easier to fix problems now than halfway through the K8s setup!

## Validation Checklist

### ✅ Basic Infrastructure
-  All 4 VMs are running
-  Static IP addresses assigned
-  SSH access working
-  Network connectivity between nodes

### ✅ Security & Access
-  Firewall rules properly configured
-  SSH keys distributed correctly
-  Root access enabled on all nodes

### ✅ Prerequisites for K8s
-  Sufficient disk space
-  Required ports accessible
-  Network routing working

## VM Status Verification

### Check All Instances Are Running
```bash
# From your local machine
terraform output vm_ips

# Or check in GCP console
gcloud compute instances list --project=YOUR_PROJECT_ID
```

Expected output:
```
NAME     ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
jumpbox  us-central1-a  e2-small                   10.128.0.2   34.90.50.182   RUNNING
server   us-central1-a  e2-small                   10.128.0.3   34.13.164.225  RUNNING
node-0   us-central1-a  e2-small                   10.128.0.4   34.32.227.137  RUNNING
node-1   us-central1-a  e2-small                   10.128.0.5   35.195.123.45  RUNNING
```

### Verify Static IP Assignment
```bash
# Check that external IPs match our Terraform outputs
gcloud compute addresses list --project=YOUR_PROJECT_ID
```

## SSH Connectivity Testing

### Test Direct Access to Jumpbox
```bash
# Test SSH to jumpbox
ssh  root@JUMPBOX_IP 'echo "Jumpbox SSH working!"'
```

### Test Access to All Cluster Nodes
```bash
# SSH to jumpbox first
ssh root@JUMPBOX_IP

# From jumpbox, test access to all nodes
while read IP FQDN HOST SUBNET; do
  echo "Testing SSH to $HOST..."
  ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@${IP} < /dev/null "echo 'SSH to $HOST successful'"
done < machines.txt
```

Expected output:
```
Testing SSH to jumpbox...
SSH to jumpbox successful
Testing SSH to server...
SSH to server successful
Testing SSH to node-0...
SSH to node-0 successful
Testing SSH to node-1...
SSH to node-1 successful
```

## Firewall Rules Verification

### Check GCP Firewall Rules
```bash
# List firewall rules for our network
gcloud compute firewall-rules list --filter="network:your-vpc"
```

You should see rules allowing:

- SSH (port 22)
- HTTP/HTTPS (ports 80, 443)
- Kubernetes API (port 6443)
- etcd (ports 2379-2380)
- Kubelet API (port 10250)
- NodePort range (30000-32767)

### Test External Connectivity
```bash
# Test that we can reach the internet from our nodes
for host in server node-0 node-1; do
  echo "Testing internet connectivity from $host..."
  ssh root@$(grep $host machines.txt | cut -d' ' -f1) 'curl -s -o /dev/null -w "%{http_code}" http://google.com'
done
```

Expected: HTTP 200 or 301 responses.

## Pre-Kubernetes Software Check

### Verify Base OS
```bash
# Check OS version on all nodes
for host in jumpbox server node-0 node-1; do
  echo "=== OS version on $host ==="
  ssh root@$(grep $host machines.txt | cut -d' ' -f1) 'cat /etc/os-release | grep PRETTY_NAME'
done
```

Expected: Debian GNU/Linux or similar.


## Next Steps

Congratulations! Your infrastructure is ready for Kubernetes installation.

Next up: [Manual Kubernetes Setup](../kubernetes/manual-setup.md) where we'll start building our cluster from scratch!

---

!!! success "Infrastructure Validated!"
    All systems green! Your infrastructure is solid and ready for the Kubernetes installation journey.
