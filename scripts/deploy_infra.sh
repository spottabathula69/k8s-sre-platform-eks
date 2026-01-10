#!/bin/bash
set -e

# Configuration
REGION="us-west-2"
CLUSTER_NAME="sre-platform-dev-eks"
TERRAFORM_DIR="infra/terraform/envs/dev"

echo "====================================================="
echo " Deploying Infrastructure (Phased Apply)"
echo "====================================================="

# Check for AWS identity
echo "--> Checking AWS identity..."
aws sts get-caller-identity --region $REGION

cd $TERRAFORM_DIR

echo "--> Initializing Terraform..."
terraform init

echo "--> Phase 1: Network (VPC)..."
terraform apply -target=module.vpc -auto-approve

echo "--> Phase 2: EKS Control Plane..."
terraform apply -target=module.eks.aws_eks_cluster.this -auto-approve

echo "--> Phase 3: Node Groups & Complete Stack..."
# Appying everything ensures dependencies like IAM roles and nodes are consistent
terraform apply -auto-approve

echo "====================================================="
echo " Infrastructure Deployed Successfully"
echo "====================================================="

# Update kubeconfig
echo "--> Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo "--> Ready for Platform Deployment!"
