# Private GKE Cluster with Terraform

This repository contains Terraform configurations to deploy a private Google Kubernetes Engine (GKE) cluster with a jump host in a custom VPC.

## Architecture Overview

The infrastructure includes:

1. **Custom VPC & Subnet** - Isolated network environment
2. **Private GKE Cluster** - Control plane with private endpoint
3. **Cloud NAT** - For outbound internet access from private instances
4. **Jump Host (Bastion)** - For secure access to the private GKE cluster
5. **IAP Tunneling** - Secure access to the jump host
6. **Service Account** - For authentication and authorization

## Prerequisites

- Google Cloud Platform account
- Service Account with appropriate permissions
- Service Usage API enabled
- Google Cloud SDK installed
- Terraform v1.x installed

## Project Structure

```
├── 01-variables.tf     # Input variables declaration
├── 02-versions.tf      # Terraform settings and provider configuration
├── 03-apis.tf          # Google Cloud APIs enablement
├── 04-network.tf       # VPC, subnet, and Cloud NAT configuration
├── 05-gke.tf           # GKE cluster and node pool configuration
├── 06-compute.tf       # Jump host VM configuration
├── 06-iam.tf           # IAM permissions and service account
└── 07-outputs.tf       # Output values
```

## Key Components

### Network Configuration (04-network.tf)
Creates a custom VPC with a subnet and Cloud NAT for outbound internet access.

### GKE Cluster (05-gke.tf)
Deploys a private GKE cluster with:
- Private control plane endpoint
- Private nodes (no public IPs)
- Custom node pool with preemptible VMs
- Master authorized networks for secure access

### Jump Host (06-compute.tf)
Provisions a bastion host with:
- Internal IP only
- Firewall rules for IAP access
- Used to access the private GKE cluster

### Authentication (06-iam.tf)
Sets up IAM permissions for:
- Service account with necessary roles
- IAP tunnel access

## Usage Instructions

### Initial Setup

1. Enable the Service Usage API manually in the Google Cloud Console:
   ```
   https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=YOUR_PROJECT_ID
   ```

2. Authenticate with Google Cloud:
   ```
   gcloud auth application-default login
   ```

3. Initialize Terraform:
   ```
   terraform init
   ```

### Deployment

1. Review the configuration:
   ```
   terraform plan
   ```

2. Apply the configuration:
   ```
   terraform apply
   ```

3. Accessing the GKE cluster:
   - SSH to the jump host using IAP tunneling:
     ```
     gcloud compute ssh jump-host --tunnel-through-iap
     ```
   - Get cluster credentials from the jump host:
     ```
     gcloud container clusters get-credentials my-gke-cluster --zone europe-central2-a
     ```

### Destruction

To destroy all resources:

1. Set deletion_protection to false for the GKE cluster:
   ```
   terraform apply -target=google_container_cluster.primary
   ```

2. Destroy all resources:
   ```
   terraform destroy
   ```

## Common Issues and Solutions

### Authentication Issues
- Ensure you have run `gcloud auth application-default login`
- Check that the service account has the necessary permissions

### API Enablement Issues
- The Service Usage API must be enabled manually before running Terraform
- After enabling an API, wait a few minutes for the change to propagate

### Deletion Protection
- The GKE cluster has deletion protection enabled by default
- Set `deletion_protection = false` in the GKE cluster resource before destroying

## Security Considerations

This setup follows security best practices:
- Private GKE cluster with no public endpoints
- Jump host accessible only through IAP
- Restricted master authorized networks
- Least privilege service account

## Customization

To customize the deployment:
- Edit variables in `01-variables.tf`
- Modify node count, machine type, or region as needed
- Adjust CIDR ranges in network and GKE configuration
