# Kubernetes The Hard way provisioning via Terraform (Google Cloud)

This repository provides you with the necessary terraform files to automate provisioning of resources in Google Cloud for the Kubernetes The Hard Way challenge by Kelsey High Tower

## Google Compute Engine Specifications

Here, you can see the recommended machine types for each instance type you will be provisioning.

| Name  | Description        | CPU | RAM | Storage | Machine Type |
|-------| -------------------|-----|-----|---------|--------------|
|jumpbox| Administration Host| 1   |512MB| 10GB    | f1.micro     |