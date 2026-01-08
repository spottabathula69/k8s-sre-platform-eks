# IAM Bootstrap Strategy

This project uses a **dedicated IAM user** for Terraform execution.

## Why AdministratorAccess was used temporarily

AWS-managed EKS policies visible in the IAM console are designed for:

- EKS control plane service roles
- Node instance roles
- Add-on and controller roles

They do **not** grant `eks:CreateCluster` to a human or CI identity.

To avoid brittle or overly complex bootstrap permissions during early bring-up,
`AdministratorAccess` was temporarily granted to the Terraform execution user.

This access is scoped to:
- A single IAM user
- A single AWS account
- A short bootstrap window

## Hardening Plan

After cluster and nodegroup bootstrap:

- Remove `AdministratorAccess`
- Replace with a scoped Terraform execution policy
- Limit EKS, EC2, IAM, and `iam:PassRole` permissions
- Enforce separation between platform and workload permissions

This mirrors real production SRE practice.
