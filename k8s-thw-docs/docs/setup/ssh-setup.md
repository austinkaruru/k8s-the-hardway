# SSH Configuration: Secure Access to Your Cluster

SSH is how we'll access and manage our Kubernetes cluster. Let's set it up properly so we can seamlessly jump between machines during the tutorial.

## SSH Key Strategy

For this lab, we'll use a dedicated SSH key pair. This keeps things organized and makes it easy to clean up later.

### Generate SSH Keys

If you haven't already created SSH keys for this project:

```bash
# Generate a new SSH key pair specifically for this project
ssh-keygen -t ed25519 -C "k8s-thw-lab" -f ~/.ssh/k8s-thw

# Set proper permissions
chmod 600 ~/.ssh/k8s-thw
chmod 644 ~/.ssh/k8s-thw.pub
```

!!! tip "Why ed25519?"
    Ed25519 keys are more secure and faster than traditional RSA keys. They're also shorter, which is nice for configuration files.

### Verify Your Keys

```bash
# Check that both keys exist
ls -la ~/.ssh/k8s-thw*

# View your public key (you'll need this for Terraform)
cat ~/.ssh/k8s-thw.pub
```

## SSH Configuration File

Let's create an SSH config to make connecting to our instances easier:

```bash
# Create or edit your SSH config
cat >> ~/.ssh/config << 'EOF'

# Kubernetes The Hard Way Lab
Host k8s-jumpbox
    HostName JUMPBOX_IP_PLACEHOLDER
    User root
    IdentityFile ~/.ssh/k8s-thw
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host k8s-server
    HostName SERVER_IP_PLACEHOLDER
    User root
    IdentityFile ~/.ssh/k8s-thw
    ProxyJump k8s-jumpbox
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host k8s-node-0
    HostName NODE_0_IP_PLACEHOLDER
    User root
    IdentityFile ~/.ssh/k8s-thw
    ProxyJump k8s-jumpbox
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host k8s-node-1
    HostName NODE_1_IP_PLACEHOLDER
    User root
    IdentityFile ~/.ssh/k8s-thw
    ProxyJump k8s-jumpbox
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

EOF
```

!!! note "IP Placeholders"
    We'll update the IP addresses after Terraform creates our infrastructure. For now, the placeholders keep the structure ready.

## Understanding the SSH Setup

### Why a Jumpbox?
- **Security**: Only one machine exposed to the internet
- **Organization**: Central point for accessing the cluster
- **Convenience**: All tools and files in one place

### SSH Configuration Explained

| Setting | Purpose |
|---------|---------|
| `ProxyJump` | Routes connections through the jumpbox |
| `StrictHostKeyChecking no` | Skips host key verification (lab only!) |
| `UserKnownHostsFile /dev/null` | Doesn't save host keys |
| `IdentityFile` | Uses our dedicated SSH key |

!!! warning "Lab-Only Settings"
    The `StrictHostKeyChecking no` setting is convenient for labs but should never be used in production!

## SSH Agent Setup

Let's add our key to the SSH agent for convenience:

```bash
# Start SSH agent if not running
eval "$(ssh-agent -s)"

# Add our key to the agent
ssh-add ~/.ssh/k8s-thw

# Verify it's loaded
ssh-add -l
```

## Testing SSH (After Infrastructure Deployment)

Once Terraform creates our infrastructure, we'll test SSH connectivity:

```bash
# Test direct connection to jumpbox
ssh k8s-jumpbox

# Test proxied connections to cluster nodes
ssh k8s-server 'hostname'
ssh k8s-node-0 'hostname'
ssh k8s-node-1 'hostname'
```

## SSH Key Distribution Strategy

Here's how SSH access will work in our setup:

1. **Local → Jumpbox**: Direct SSH using our private key
2. **Jumpbox → Cluster**: We'll copy our private key to the jumpbox
3. **Cluster Communication**: All nodes can SSH to each other

### Security Considerations

!!! danger "Private Key on Jumpbox"
    We'll copy our private key to the jumpbox for convenience during the tutorial. In production, you'd use SSH agent forwarding or a bastion host setup instead.

## Preparing for the Tutorial

The original Kubernetes The Hard Way tutorial expects:
- Root access to all machines
- SSH keys distributed for passwordless access
- A jumpbox with all necessary tools

Our Terraform setup handles most of this automatically, but we'll need to:
1. Copy our private key to the jumpbox after deployment
2. Update our SSH config with actual IP addresses
3. Test connectivity to all nodes

## What's Next?

With SSH configured, we're ready to move on to the [Terraform deployment](../infrastructure/terraform-overview.md) where we'll actually create our infrastructure!

The SSH setup might seem like overkill for a lab, but having proper access patterns makes the rest of the tutorial much smoother.

---

!!! tip "SSH Troubleshooting"
    If you run into SSH issues later, check the [troubleshooting guide](../lessons/troubleshooting.md#ssh-issues) for common solutions.
