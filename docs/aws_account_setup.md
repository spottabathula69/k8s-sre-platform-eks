# AWS Account Setup

This project uses a **dedicated AWS CLI profile** to ensure:

- Clear account isolation  
- Safe creation and destruction of infrastructure  
- No accidental usage of personal or production AWS accounts  

---

## Required environment variables

All Terraform and AWS CLI commands assume:

```bash
export AWS_PROFILE=sre-platform
export AWS_REGION=us-west-2
```

> Set these variables **before** running Terraform or `kubectl` commands.

---

## Configure the AWS CLI profile

Create the AWS CLI profile used by this project:

```bash
aws configure --profile sre-platform
```

You will be prompted for:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name:** `us-west-2`
- **Default output format:** `json`

---

## Verify AWS access

Confirm the profile is working correctly:

```bash
AWS_PROFILE=sre-platform aws sts get-caller-identity
```

You should see your AWS account ID and IAM principal ARN.

---

## Required AWS permissions

The IAM identity behind the `sre-platform` profile must be able to create and destroy:

### Networking

- VPC
- Subnets
- Route tables
- Internet Gateway
- Security Groups

### Kubernetes / Compute

- EKS clusters
- Managed node groups
- EC2 instances
- Launch templates (if used)

### IAM

- IAM roles and policies for:
  - EKS control plane
  - Worker nodes

### Observability (optional but recommended)

- CloudWatch Logs

> **Cost-optimized note:** This project intentionally avoids NAT Gateways and other high-cost managed services in early stages.

---

## Recommended workflow

Export the environment variables once per terminal session:

```bash
export AWS_PROFILE=sre-platform
export AWS_REGION=us-west-2
```

(Optional) Persist them in your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export AWS_PROFILE=sre-platform
export AWS_REGION=us-west-2
```

---

## Why use a dedicated AWS profile?

Using a dedicated AWS CLI profile ensures:

- Clear separation between development and other AWS accounts
- Safe `terraform destroy` without risk to unrelated infrastructure
- Reproducibility for reviewers cloning this repository
