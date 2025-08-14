resource "google_compute_address" "vm_ip" {
  name   = "${var.node_name}-ip"
  region = var.region
}

resource "google_compute_disk" "vm_disk" {
  name  = "${var.node_name}-disk"
  type  = var.boot_disk
  image = var.image_type
  zone  = var.zone
  size  = var.size
}

resource "google_compute_instance" "vm" {
  name         = var.node_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags
  allow_stopping_for_update = true

  # Enable OS Login (this is important for SSH key management)
  metadata = {
    enable-oslogin = "FALSE"
    ssh-keys = "${var.ssh_username}:${trimspace(file(var.ssh_key))}\nroot:${trimspace(file(var.ssh_key))}"
    # Completely disable Google's hostname and domain management
    enable-guest-attributes = "FALSE"
    enable-wsfc = "FALSE"
  }

  boot_disk {
    source      = google_compute_disk.vm_disk.id
    auto_delete = true
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    
    # Wait a moment for the system to fully initialize
    sleep 10
    
    # Add user to sudoers
    echo "${var.ssh_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${var.ssh_username}
    chmod 440 /etc/sudoers.d/${var.ssh_username}
    
    # Configure SSH for root access
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Enable root login with public key authentication
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # Ensure root's SSH directory exists and has correct permissions
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    
    # Copy the SSH key to root's authorized_keys
    if [ -f /home/${var.ssh_username}/.ssh/authorized_keys ]; then
        cp /home/${var.ssh_username}/.ssh/authorized_keys /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        chown root:root /root/.ssh/authorized_keys
    fi
    
    # Restart SSH service
    systemctl restart sshd
    systemctl enable sshd
    
    # PERMANENTLY disable GCP hostname management
    systemctl stop google-hostname-daemon || true
    systemctl disable google-hostname-daemon || true
    systemctl mask google-hostname-daemon || true
    
    # Remove any existing hostname override files
    rm -f /etc/hostname.override
    
    # Set the custom hostname based on node name - PERMANENT SETTING
    case "${var.node_name}" in
        "server")
            echo "server.kubernetes.local" > /etc/hostname
            hostnamectl set-hostname server.kubernetes.local
            sed -i '/127.0.1.1/d' /etc/hosts
            echo "127.0.1.1 server.kubernetes.local server" >> /etc/hosts
            ;;
        "node-0")
            echo "node-0.kubernetes.local" > /etc/hostname  
            hostnamectl set-hostname node-0.kubernetes.local
            sed -i '/127.0.1.1/d' /etc/hosts
            echo "127.0.1.1 node-0.kubernetes.local node-0" >> /etc/hosts
            ;;
        "node-1")
            echo "node-1.kubernetes.local" > /etc/hostname
            hostnamectl set-hostname node-1.kubernetes.local
            sed -i '/127.0.1.1/d' /etc/hosts
            echo "127.0.1.1 node-1.kubernetes.local node-1" >> /etc/hosts
            ;;
        "jumpbox")
            echo "jumpbox.kubernetes.local" > /etc/hostname
            hostnamectl set-hostname jumpbox.kubernetes.local
            sed -i '/127.0.1.1/d' /etc/hosts
            echo "127.0.1.1 jumpbox.kubernetes.local jumpbox" >> /etc/hosts
            ;;
    esac
    
    # Make sure hostname persists across reboots
    systemctl restart systemd-hostnamed
    
    # Create a systemd service to enforce hostname on boot (belt and suspenders approach)
    cat > /etc/systemd/system/set-custom-hostname.service << EOSVC
[Unit]
Description=Set Custom Hostname
After=network.target
Before=google-hostname-daemon.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'hostnamectl set-hostname \$(cat /etc/hostname)'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOSVC
    
    # Enable the custom hostname service
    systemctl enable set-custom-hostname.service
    
    # Log completion
    echo "SSH and hostname configuration completed at $(date)" >> /var/log/startup-script.log
  EOT

  network_interface {
    network = var.network_name
    subnetwork = var.node_name == "node-0" ? var.node_0_subnet : (
                 var.node_name == "node-1" ? var.node_1_subnet : var.management_subnet
                )
    access_config {
      nat_ip = google_compute_address.vm_ip.address
    }
  }

  service_account {
    email  = var.tf_sa
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}