# Bootstrap Guide (Terraform + EKS)

This document captures the bring-up workflow and the IAM bootstrap decision used for this repo.

---

## IAM Bootstrap Permissions (Temporary)

During initial infrastructure bootstrap, the Terraform execution identity must be able to:

- Create and manage the EKS control plane (`eks:CreateCluster`)
- Create IAM roles and pass them to AWS services (`iam:PassRole`)
- Manage EC2 networking resources (VPC, subnets, ENIs, security groups)

For initial bring-up, the dedicated IAM user was granted temporary `AdministratorAccess`
to unblock cluster creation. This permission should be removed and replaced with a
least-privilege Terraform execution policy after cluster + node bootstrap is stable.

---

## Phased Terraform Apply

### Phase 1 — VPC only

```bash
cd infra/terraform/envs/dev
terraform init
terraform apply -target=module.vpc -auto-approve
```

### Phase 2 — EKS control plane (no nodes)
```bash
terraform apply -target=module.eks.aws_eks_cluster.this -auto-approve
```
Validate cluster status:

```bash
aws eks describe-cluster \
  --name k8s-sre-platform-dev-eks \
  --region us-west-2 \
  --query "cluster.status"
```
### Phase 3 — Node group
```bash
terraform apply -target=module.eks.aws_eks_node_group.default -auto-approve
```

Update kubeconfig and verify access:
```bash
aws eks update-kubeconfig \
  --name k8s-sre-platform-dev-eks \
  --region us-west-2

kubectl get ns
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

Destroy infrastructure when finished:

```bash
terraform destroy -auto-approve
```