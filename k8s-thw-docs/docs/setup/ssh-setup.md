# SSH Configuration: Secure Access to Your Cluster

SSH is how we'll access and manage our Kubernetes cluster. Let's set it up properly so we can seamlessly jump between machines during the tutorial.

## SSH Key Strategy

For this lab, we'll use a dedicated SSH key pair. This keeps things organized and makes it easy to clean up later.

### Generate SSH Keys

If you haven't already created SSH keys for this project:

```bash
# Generate a new SSH key pair specifically for this project
ssh-keygen -t ed25519

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

!!! tip "Why ed25519?"
    Ed25519 keys are more secure and faster than traditional RSA keys. They're also shorter, which is nice for configuration files.

### Verify Your Keys

```bash
# Check that both keys exist
ls -la ~/.ssh/id_ed25519*

# View your public key (you'll need this for Terraform)
cat ~/.ssh/id_ed25519.pub
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

Our Terraform setup handles most of this automatically, but we'll need to copy our private key to the jumpbox after deployment

## What's Next?

With SSH configured, we're ready to move on to the [Terraform deployment](../infrastructure/terraform-overview.md) where we'll actually create our infrastructure!

The SSH setup might seem like overkill for a lab, but having proper access patterns makes the rest of the tutorial much smoother.

---

!!! tip "SSH Troubleshooting"
    If you run into SSH issues later, check the [troubleshooting guide](../lessons/troubleshooting.md#ssh-issues) for common solutions.
