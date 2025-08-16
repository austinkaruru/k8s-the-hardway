# Prerequisites: Getting Your Environment Ready

Before we dive into the fun stuff, let's make sure we have all the tools we need. Trust me, spending time on proper setup now will save you hours of debugging later!

## Required Tools

### Terraform
We're using Terraform to manage our infrastructure because clicking around in the GCP console gets old fast.

=== "Linux"
    ```bash
    # Ubuntu/Debian
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    
    # RHEL/CentOS/Fedora
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install terraform
    
    # Arch Linux
    sudo pacman -S terraform
    
    # Or download binary directly
    wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
    unzip terraform_1.5.7_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    ```

=== "macOS"
    ```bash
    # With Homebrew (recommended)
    brew install terraform
    
    # Or download from https://www.terraform.io/downloads.html
    ```

=== "Windows"
    ```powershell
    # With Chocolatey
    choco install terraform
    
    # With Scoop
    scoop install terraform
    
    # Or download from https://www.terraform.io/downloads.html
    # Extract to a directory in your PATH
    ```

Verify installation:
```bash
terraform --version
```

!!! tip "Version Compatibility"
    I'm using Terraform >= 1.0. Older versions might work, but why risk it?

### Google Cloud SDK
You'll need the `gcloud` CLI to interact with Google Cloud Platform.

=== "Linux"
    ```bash
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    # Import the Google Cloud public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    
    # Update and install the Cloud SDK
    sudo apt-get update && sudo apt-get install google-cloud-cli
    
    # Or use the install script
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    ```

=== "macOS"
    ```bash
    # With Homebrew
    brew install --cask google-cloud-sdk
    
    # Or use the install script
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    ```

=== "Windows"
    ```powershell
    # Download and run the installer from:
    # https://cloud.google.com/sdk/docs/install-sdk#windows
    
    # Or with Chocolatey
    choco install gcloudsdk
    ```

Initialize and authenticate:
```bash
gcloud init
gcloud auth application-default login
```

### SSH Key Pair
We need SSH keys to access our instances. If you don't have one already:

=== "Linux/macOS"
    ```bash
    # Generate a new SSH key pair
    ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/k8s-thw
    
    # This creates:
    # ~/.ssh/k8s-thw (private key)
    # ~/.ssh/k8s-thw.pub (public key)
    
    # Set proper permissions
    chmod 600 ~/.ssh/k8s-thw
    chmod 644 ~/.ssh/k8s-thw.pub
    ```

=== "Windows"
    ```powershell
    # Using OpenSSH (Windows 10/11)
    ssh-keygen -t ed25519 -C "your-email@example.com" -f %USERPROFILE%\.ssh\k8s-thw
    
    # Or use PuTTY Key Generator (PuTTYgen) if you prefer
    # Download from: https://www.putty.org/
    ```

!!! warning "Keep Your Private Key Safe"
    Never share your private key or commit it to version control!

## System Requirements

### Local Machine
- **OS**: Linux, macOS, or Windows with WSL2/PowerShell
- **RAM**: At least 4GB (8GB recommended)
- **Storage**: 10GB free space for tools and temporary files
- **Network**: Reliable internet connection for downloading tools and accessing GCP

### Google Cloud Account
- Active GCP account with billing enabled
- Project with sufficient quota for:
    - 4 x e2-small instances
    - 1 custom VPC
    - Static IP addresses

## Additional Tools (Optional but Helpful)

### Text Editor
You'll be editing configuration files, so having a good editor helps:

=== "Linux"
    ```bash
    # Vim (if you're comfortable with it)
    sudo apt install vim  # Ubuntu/Debian
    sudo dnf install vim  # RHEL/Fedora
    
    # Nano (simpler for beginners)
    sudo apt install nano  # Ubuntu/Debian
    sudo dnf install nano  # RHEL/Fedora
    
    # VS Code
    # Download from https://code.visualstudio.com/
    ```

=== "macOS"
    ```bash
    # VS Code
    brew install --cask visual-studio-code
    
    # Vim is usually pre-installed
    # Nano is usually pre-installed
    ```

=== "Windows"
    ```powershell
    # VS Code
    choco install vscode
    
    # Notepad++ 
    choco install notepadplusplus
    ```

### Git (for version control)
While not strictly required, it's good practice to version control your infrastructure:

=== "Linux"
    ```bash
    # Ubuntu/Debian
    sudo apt install git
    
    # RHEL/Fedora
    sudo dnf install git
    ```

=== "macOS"
    ```bash
    # Usually pre-installed, or:
    brew install git
    ```

=== "Windows"
    ```powershell
    # With Chocolatey
    choco install git
    
    # Or download from https://git-scm.com/
    ```

## Cost Considerations

Let's be real about costs. Running this lab isn't free, but it's not expensive either:

| Resource | Quantity | Estimated Cost/Hour |
|----------|----------|-------------------|
| e2-small instances | 4 | ~$0.20 |
| Static IPs | 4 | ~$0.02 |
| Network egress | Minimal | ~$0.01 |
| **Total** | | **~$0.23/hour** |

!!! tip "Cost Optimization"
    - Destroy resources when not using them
    - Use `terraform destroy` after each session
    - Set up billing alerts in GCP
    - Consider using preemptible instances for even lower costs (though they can be terminated)

## Verification Checklist

Before moving on, make sure you can run these commands successfully:

```bash
# Check Terraform
terraform --version
# Should show: Terraform v1.x.x

# Check gcloud
gcloud --version
# Should show: Google Cloud SDK xxx.x.x

# Check authentication
gcloud auth list
# Should show your authenticated account

# Check SSH key exists
ls -la ~/.ssh/k8s-thw*  # Linux/macOS
dir %USERPROFILE%\.ssh\k8s-thw*  # Windows
# Should show both private and public key files
```

## Platform-Specific Notes

### Linux Users
- Most distributions come with SSH client pre-installed
- Package managers make tool installation straightforward
- File permissions are important for SSH keys (`chmod 600` for private keys)

### macOS Users
- Homebrew is the easiest way to install most tools
- SSH client is pre-installed
- File permissions work the same as Linux

### Windows Users
- Windows 10/11 includes OpenSSH client
- PowerShell or Command Prompt both work
- Consider using Windows Subsystem for Linux (WSL2) for a more Unix-like experience
- File paths use backslashes (`\`) instead of forward slashes (`/`)

## What's Next?

Once you've got all the prerequisites sorted, we'll move on to [setting up your GCP project](gcp-setup.md) with all the necessary APIs and service accounts.

The setup might seem tedious, but trust me - having everything configured properly from the start makes the rest of the journey much smoother!

---

!!! question "Having Issues?"
    If you run into problems with any of these tools, check out the [troubleshooting section](../lessons/troubleshooting.md) for common solutions.
