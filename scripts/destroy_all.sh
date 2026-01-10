#!/bin/bash
set -e

TERRAFORM_DIR="infra/terraform/envs/dev"

echo "====================================================="
echo " DESTROYING ALL INFRASTRUCTURE"
echo "====================================================="
echo "WARNING: This will delete the EKS cluster and all data."
read -p "Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

cd $TERRAFORM_DIR

echo "--> Destroying Infrastructure..."
terraform destroy -auto-approve

echo "====================================================="
echo " Destruction Complete. Money saved!"
echo "====================================================="
