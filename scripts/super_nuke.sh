#!/bin/bash
# scripts/super_nuke.sh
# WARNING: DELETES EVERYTHING IN THE VPC.

VPC_ID="vpc-04d879a660ff41b1c"
REGION="us-west-2"

echo "====================================================="
echo " SUPER NUKE CLEANUP: $VPC_ID"
echo "====================================================="

# Function to run aws command
aws_cmd() {
    aws "$@" --region $REGION --output text
}

echo "--> 1. Finding Network Interfaces..."
ENIS=$(aws_cmd ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkInterfaces[*].NetworkInterfaceId")

if [ -n "$ENIS" ]; then
    for ENI in $ENIS; do
        echo "   Targeting ENI: $ENI"
        # Try to detach first if attached
        ATTACHMENT=$(aws_cmd ec2 describe-network-interfaces --network-interface-ids $ENI --query "NetworkInterfaces[0].Attachment.AttachmentId")
        if [ "$ATTACHMENT" != "None" ] && [ -n "$ATTACHMENT" ]; then
            echo "   Detaching $ATTACHMENT..."
            aws_cmd ec2 detach-network-interface --attachment-id "$ATTACHMENT" --force || echo "   Detach failed (might be primary)"
            sleep 2
        fi
        
        echo "   Deleting $ENI..."
        aws_cmd ec2 delete-network-interface --network-interface-id "$ENI" || echo "   Delete failed (likely still attached)"
    done
else
    echo "   No ENIs found."
fi

echo "--> 2. Clearing Security Group Rules (Break Dependencies)..."
SGS=$(aws_cmd ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[*].GroupId")

if [ -n "$SGS" ]; then
    for SG in $SGS; do
        echo "   Revoking rules for $SG..."
        # Ingress
        aws_cmd ec2 revoke-security-group-ingress --group-id "$SG" --protocol all --source-group "$SG" || true # Self-ref
        aws_cmd ec2 describe-security-groups --group-ids "$SG" --query "SecurityGroups[0].IpPermissions" > ingress.json
        # NOTE: Parsing complex rules in bash is hard. We rely on the fact that if we delete ENIs first, SGs usually become deletable unless circular.
        # Simple nuclear revoke all usually requires knowing the exact rule.
        # Instead, we will retry SG deletion at the end.
    done
fi

echo "--> 3. Deleting Subnets..."
SUBNETS=$(aws_cmd ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId")
if [ -n "$SUBNETS" ]; then
    for SUBNET in $SUBNETS; do
        echo "   Deleting Subnet: $SUBNET"
        aws_cmd ec2 delete-subnet --subnet-id "$SUBNET" || echo "   Failed to delete subnet (still has ENIs?)"
    done
else
    echo "   No Subnets found."
fi

echo "--> 4. Deleting Internet Gateways..."
IGWS=$(aws_cmd ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[*].InternetGatewayId")
if [ -n "$IGWS" ]; then
    for IGW in $IGWS; do
        echo "   Detaching $IGW..."
        aws_cmd ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID"
        echo "   Deleting $IGW..."
        aws_cmd ec2 delete-internet-gateway --internet-gateway-id "$IGW"
    done
else
    echo "   No IGWs found."
fi

echo "--> 5. Final Security Group Deletion..."
if [ -n "$SGS" ]; then
    for SG in $SGS; do
        if [ "$SG" != "default" ]; then
             echo "   Deleting SG: $SG"
             aws_cmd ec2 delete-security-group --group-id "$SG" || echo "   Failed to delete SG (dependencies?)"
        fi
    done
fi

echo "--> 6. Deleting VPC..."
aws_cmd ec2 delete-vpc --vpc-id "$VPC_ID" && echo "VPC DELETED SUCCESSFULLY!" || echo "VPC Delete Failed."

echo "====================================================="
echo " Cleanup Attempt Complete."
echo "====================================================="
