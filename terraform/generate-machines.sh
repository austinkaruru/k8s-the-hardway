#!/bin/bash

# Helper script to generate machines.txt with correct project-specific hostnames
# This ensures users get the right hostnames for their GCP project

set -e

echo "Generating machines.txt with project-specific hostnames..."

# Get current project ID and zone from terraform or gcloud
PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || gcloud config get-value project)

# Try to get zone from terraform variables, fallback to default
ZONE=$(grep 'zone.*=' terraform.tfvars 2>/dev/null | cut -d'"' -f2 || echo "europe-west4-a")
if [ -z "$ZONE" ]; then
    ZONE="europe-west4-a"  # Default zone used in this project
fi

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Could not determine project ID. Make sure you're in a terraform directory or have gcloud configured."
    exit 1
fi

echo "Using Project ID: $PROJECT_ID"
echo "Using Zone: $ZONE"

# Generate machines.txt with correct hostnames
terraform output -json vm_ips | jq -r --arg project_id "$PROJECT_ID" --arg zone "$ZONE" '
  "# GCP Internal FQDN format: {instance}.{zone}.c.{project-id}.internal",
  "# Generated for project: " + $project_id + " in zone: " + $zone,
  (.server + " server." + $zone + ".c." + $project_id + ".internal server"), 
  (."node-0" + " node-0." + $zone + ".c." + $project_id + ".internal node-0 10.200.0.0/24"),
  (."node-1" + " node-1." + $zone + ".c." + $project_id + ".internal node-1 10.200.1.0/24")
' > machines.txt

echo "✅ Generated machines.txt with hostnames for project: $PROJECT_ID"
echo "📄 Contents:"
cat machines.txt
