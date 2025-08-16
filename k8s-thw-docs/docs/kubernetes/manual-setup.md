# Manual Kubernetes Setup: The Real Journey Begins

Now comes the main event - manually installing and configuring every component of a Kubernetes cluster! This is where we really learn how Kubernetes works under the hood.

## What We're Building

By the end of this process, we'll have a fully functional Kubernetes cluster with:

- **1 Control Plane Node** (`server`) running:
  - etcd (the cluster database)
  - kube-apiserver (the Kubernetes API)
  - kube-controller-manager (cluster control loops)
  - kube-scheduler (pod placement decisions)

- **2 Worker Nodes** (`node-0`, `node-1`) running:
  - kubelet (node agent)
  - kube-proxy (network proxy)
  - containerd (container runtime)

- **Network Configuration** for:
  - Pod-to-pod communication
  - Service discovery
  - External access

## The Journey Ahead

### Phase 1: Certificate Authority & TLS
First, we'll create our own Certificate Authority and generate all the TLS certificates that Kubernetes components need to communicate securely.

**Why this matters:** Kubernetes is security-first. Every component authenticates using certificates, and understanding this is crucial for production deployments.

### Phase 2: Configuration Files
We'll create kubeconfig files that tell each component how to connect to the API server and authenticate.

**Why this matters:** These config files are how kubectl, kubelet, and other components know where to find the API server and how to authenticate.

### Phase 3: Data Store (etcd)
We'll install and configure etcd, the distributed key-value store that holds all cluster state.

**Why this matters:** etcd is the brain of Kubernetes. If etcd goes down, your cluster is effectively dead.

### Phase 4: Control Plane
We'll install and configure the three main control plane components that make Kubernetes work.

**Why this matters:** Understanding how these components interact helps you troubleshoot issues and optimize performance.

### Phase 5: Worker Nodes
We'll set up the worker nodes where your actual workloads will run.

**Why this matters:** This is where the rubber meets the road - where containers actually run and do work.

### Phase 6: Networking
We'll configure pod networking so containers can communicate across nodes.

**Why this matters:** Without proper networking, you don't have a cluster - just isolated nodes.

## Before We Start

### Set Up Your Workspace
```bash
# SSH to the jumpbox - this is our command center
ssh -i ~/.ssh/k8s-thw root@JUMPBOX_IP

# Verify we can reach all nodes
while read IP FQDN HOST SUBNET; do
  echo "Testing $HOST..."
  ssh -i /root/.ssh/k8s-thw -o StrictHostKeyChecking=no root@${IP} hostname
done < machines.txt
```

### Install Required Tools
```bash
# Install tools we'll need on the jumpbox
apt update
apt install -y wget curl

# Create a workspace directory
mkdir -p ~/k8s-setup
cd ~/k8s-setup
```

## The Learning Mindset

### What Makes This "Hard"
- **No automation** - every step is manual
- **Deep understanding required** - you need to know what each component does
- **Lots of moving parts** - certificates, configs, networking, etc.
- **Easy to make mistakes** - one typo can break everything

### What Makes It Worth It
- **Real understanding** of how Kubernetes works
- **Troubleshooting skills** that transfer to any K8s environment
- **Appreciation** for managed services like GKE, EKS, AKS
- **Confidence** in production Kubernetes deployments

## My Experience So Far

### The Good
- **"Aha!" moments** when you see how components connect
- **Solid foundation** for understanding any Kubernetes environment
- **Debugging skills** that come from building it yourself
- **Appreciation** for the complexity that managed services hide

### The Challenging
- **Time investment** - this isn't a quick tutorial
- **Attention to detail** - small mistakes cascade
- **Patience required** - things will break, and that's okay
- **Documentation diving** - you'll read a lot of man pages

## Success Tips

### 1. Take Your Time
Don't rush. Each step builds on the previous ones, so make sure you understand what you're doing before moving on.

### 2. Test Everything
After each major step, test that things are working. It's much easier to debug one component than a whole broken cluster.

### 3. Keep Notes
Document what you're doing and why. You'll thank yourself later when you need to troubleshoot or explain something.

### 4. Embrace the Failures
When something doesn't work (and it will), that's a learning opportunity. Figure out why it failed - that's where the real learning happens.

### 5. Use the Documentation
The original [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) guide is excellent. I'm documenting my experience, but refer to the original for authoritative instructions.

## What's Different in My Setup

### Infrastructure Automation
Unlike the original tutorial, we used Terraform to create our infrastructure. This means:
- ✅ Consistent, reproducible environment
- ✅ Easy to tear down and rebuild if needed
- ✅ Infrastructure as Code best practices

### Documentation Focus
I'm documenting not just the steps, but:
- Why each step is necessary
- What can go wrong
- How to troubleshoot issues
- Lessons learned along the way

## Ready to Begin?

The infrastructure is ready, the tools are installed, and we have a solid foundation. 

Let's start with [creating our Certificate Authority](certificates.md) - the security foundation of our cluster!

Remember: this is a journey, not a race. Take your time, understand each step, and don't be afraid to experiment.

---

!!! tip "Bookmark This Page"
    You'll probably want to come back to this overview as you work through the setup. Each phase builds on the previous ones, so this roadmap helps keep the big picture in mind.
