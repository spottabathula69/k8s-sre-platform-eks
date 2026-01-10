#!/bin/bash
set -e

VPC_ID="vpc-04d879a660ff41b1c"
REGION="us-west-2"

echo "====================================================="
echo " Force Cleanup for VPC: $VPC_ID"
echo "====================================================="

# 1. Classic ELBs (v1)
echo "--> Checking for Classic Load Balancers..."
ELBS=$(aws elb describe-load-balancers --region $REGION --query "LoadBalancerDescriptions[?VPCId=='$VPC_ID'].LoadBalancerName" --output text)

if [ -n "$ELBS" ]; then
    for elb in $ELBS; do
        echo "Deleting ELB: $elb"
        aws elb delete-load-balancer --region $REGION --load-balancer-name "$elb"
    done
    echo "Waiting 15s for ELB deletion..."
    sleep 15
else
    echo "No Classic ELBs found."
fi

# 2. ELB v2 (ALB/NLB)
echo "--> Checking for ALB/NLBs..."
ALBS=$(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text)

if [ -n "$ALBS" ]; then
    for arn in $ALBS; do
        echo "Deleting ELBv2: $arn"
        aws elbv2 delete-load-balancer --region $REGION --load-balancer-arn "$arn"
    done
    echo "Waiting 15s for ELB deletion..."
    sleep 15
else
    echo "No ALB/NLBs found."
fi

# 3. Security Groups (that might be stuck)
# (Optional: Sometimes SGs block things, but usually it's ENIs)

# 4. Dangling ENIs
echo "--> Checking for dangling ENIs (non-primary)..."
# We exclude 'Primary network interface' to avoid messing with active EC2 instances (though there shouldn't be any if TF destroy worked partially)
ENIS=$(aws ec2 describe-network-interfaces --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkInterfaces[?Description!='Primary network interface'].NetworkInterfaceId" --output text)

if [ -n "$ENIS" ]; then
    for eni in $ENIS; do
        echo "Deleting ENI: $eni"
        # Attempt delete (might fail if still attached, but worth a try)
        aws ec2 delete-network-interface --region $REGION --network-interface-id "$eni" || echo "WARN: Copuld not delete $eni (might be attached)"
    done
else
    echo "No dangling ENIs found."
fi

echo "====================================================="
echo " Cleanup steps complete. Try running 'terraform destroy' again."
echo "====================================================="
