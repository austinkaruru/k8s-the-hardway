# Infrastructure Validation: Making Sure Everything Works

Before we dive into Kubernetes installation, let's thoroughly test our infrastructure to catch any issues early. Trust me, it's much easier to fix problems now than halfway through the K8s setup!

## Validation Checklist

### ✅ Basic Infrastructure
- [ ] All 4 VMs are running
- [ ] Static IP addresses assigned
- [ ] SSH access working
- [ ] Network connectivity between nodes

### ✅ Security & Access
- [ ] Firewall rules properly configured
- [ ] SSH keys distributed correctly
- [ ] Root access enabled on all nodes

### ✅ Prerequisites for K8s
- [ ] Sufficient disk space
- [ ] Required ports accessible
- [ ] Network routing working

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
ssh -i ~/.ssh/k8s-thw root@JUMPBOX_IP 'echo "Jumpbox SSH working!"'
```

### Test Access to All Cluster Nodes
```bash
# SSH to jumpbox first
ssh -i ~/.ssh/k8s-thw root@JUMPBOX_IP

# From jumpbox, test access to all nodes
while read IP FQDN HOST SUBNET; do
  echo "Testing SSH to $HOST..."
  ssh -i /root/.ssh/k8s-thw -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@${IP} "echo 'SSH to $HOST successful'"
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

## Network Connectivity Testing

### Internal Network Communication
```bash
# From jumpbox, test internal network connectivity
while read IP FQDN HOST SUBNET; do
  echo "Testing ping to $HOST..."
  ping -c 2 $IP
done < machines.txt
```

### Port Accessibility Testing
Let's verify that the ports we need for Kubernetes are accessible:

```bash
# Test from jumpbox to server (control plane)
nc -zv SERVER_IP 6443  # Kubernetes API
nc -zv SERVER_IP 2379  # etcd client
nc -zv SERVER_IP 2380  # etcd peer

# Test from jumpbox to worker nodes
nc -zv NODE_0_IP 10250  # Kubelet API
nc -zv NODE_1_IP 10250  # Kubelet API
```

!!! note "Expected Behavior"
    These tests might show "Connection refused" initially - that's normal since we haven't installed Kubernetes yet. We're just checking that the ports aren't blocked by firewalls.

## System Resource Verification

### Check Disk Space
```bash
# Run on each node to verify sufficient disk space
for host in jumpbox server node-0 node-1; do
  echo "=== Disk space on $host ==="
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'df -h /'
done
```

Expected: At least 5GB free on each node.

### Check Memory
```bash
# Verify memory on each node
for host in jumpbox server node-0 node-1; do
  echo "=== Memory on $host ==="
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'free -h'
done
```

Expected: ~2GB total memory on each e2-small instance.

### Check CPU
```bash
# Verify CPU cores
for host in jumpbox server node-0 node-1; do
  echo "=== CPU info for $host ==="
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'nproc'
done
```

Expected: 2 CPU cores on each instance.

## Firewall Rules Verification

### Check GCP Firewall Rules
```bash
# List firewall rules for our network
gcloud compute firewall-rules list --filter="network:k8s-thw-vpc"
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
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'curl -s -o /dev/null -w "%{http_code}" http://google.com'
done
```

Expected: HTTP 200 or 301 responses.

## Pre-Kubernetes Software Check

### Verify Base OS
```bash
# Check OS version on all nodes
for host in jumpbox server node-0 node-1; do
  echo "=== OS version on $host ==="
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'cat /etc/os-release | grep PRETTY_NAME'
done
```

Expected: Ubuntu 20.04 LTS or similar.

### Check for Required Tools
```bash
# Verify basic tools are available
for host in jumpbox server node-0 node-1; do
  echo "=== Checking tools on $host ==="
  ssh -i /root/.ssh/k8s-thw root@$(grep $host machines.txt | cut -d' ' -f1) 'which curl wget tar'
done
```

## Validation Summary Script

Here's a comprehensive validation script you can run:

```bash
#!/bin/bash
# Save this as validate-infrastructure.sh

echo "=== Infrastructure Validation ==="
echo

# Test SSH connectivity
echo "1. Testing SSH connectivity..."
while read IP FQDN HOST SUBNET; do
  if ssh -i /root/.ssh/k8s-thw -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@${IP} 'echo "OK"' >/dev/null 2>&1; then
    echo "  ✅ $HOST ($IP) - SSH OK"
  else
    echo "  ❌ $HOST ($IP) - SSH FAILED"
  fi
done < machines.txt

echo

# Test network connectivity
echo "2. Testing network connectivity..."
while read IP FQDN HOST SUBNET; do
  if ping -c 1 -W 2 $IP >/dev/null 2>&1; then
    echo "  ✅ $HOST ($IP) - Ping OK"
  else
    echo "  ❌ $HOST ($IP) - Ping FAILED"
  fi
done < machines.txt

echo

# Check disk space
echo "3. Checking disk space..."
while read IP FQDN HOST SUBNET; do
  DISK_USAGE=$(ssh -i /root/.ssh/k8s-thw -o StrictHostKeyChecking=no root@${IP} 'df / | tail -1 | awk "{print \$5}"' 2>/dev/null | tr -d '%')
  if [ "$DISK_USAGE" -lt 80 ]; then
    echo "  ✅ $HOST - Disk usage: ${DISK_USAGE}%"
  else
    echo "  ⚠️  $HOST - Disk usage: ${DISK_USAGE}% (high)"
  fi
done < machines.txt

echo
echo "=== Validation Complete ==="
```

## Common Issues and Solutions

### SSH Connection Issues
```bash
# If SSH fails, check:
# 1. Instance is running
gcloud compute instances list

# 2. Firewall allows SSH
gcloud compute firewall-rules list --filter="name:*ssh*"

# 3. SSH key is correct
cat ~/.ssh/k8s-thw.pub
```

### Network Connectivity Issues
```bash
# Check VPC and subnet configuration
gcloud compute networks list
gcloud compute networks subnets list --network=k8s-thw-vpc
```

### Resource Constraints
```bash
# If resources are insufficient, you can resize instances
# (This will require stopping and starting them)
gcloud compute instances set-machine-type INSTANCE_NAME \
  --machine-type=e2-medium --zone=us-central1-a
```

## Next Steps

If all validations pass, congratulations! Your infrastructure is ready for Kubernetes installation.

Next up: [Manual Kubernetes Setup](../kubernetes/manual-setup.md) where we'll start building our cluster from scratch!

---

!!! success "Infrastructure Validated!"
    All systems green! Your infrastructure is solid and ready for the Kubernetes installation journey.
