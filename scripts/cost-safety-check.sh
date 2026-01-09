#!/usr/bin/env bash
set -euo pipefail

# Cost Safety Check for k8s-sre-platform
#
# Usage:
#   AWS_PROFILE=sre-platform AWS_REGION=us-west-2 ./scripts/cost-safety-check.sh
#
# Optional:
#   PROJECT_TAG_KEY=Project PROJECT_TAG_VALUE=k8s-sre-platform ./scripts/cost-safety-check.sh

AWS_REGION="${AWS_REGION:-us-west-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"

PROJECT_TAG_KEY="${PROJECT_TAG_KEY:-Project}"
PROJECT_TAG_VALUE="${PROJECT_TAG_VALUE:-k8s-sre-platform}"

# If you want to strictly fail when *any* EKS cluster exists in the region, keep STRICT_EKS=true.
# If you want to only check project-tagged resources, set STRICT_EKS=false.
STRICT_EKS="${STRICT_EKS:-true}"

aws_cli() {
  aws --region "$AWS_REGION" --profile "$AWS_PROFILE" "$@"
}

section() {
  echo
  echo "=============================="
  echo "$1"
  echo "=============================="
}

failures=0

check() {
  local name="$1"
  local cmd="$2"
  local expect_empty="${3:-true}"

  echo
  echo "-> $name"
  # shellcheck disable=SC2086
  local out
  set +e
  out=$(eval "$cmd" 2>/dev/null)
  local rc=$?
  set -e

  if [[ $rc -ne 0 ]]; then
    echo "   WARN: command failed (rc=$rc). Output:"
    echo "$out"
    echo "   (This may be permissions or a missing API. Treat as manual verification needed.)"
    return 0
  fi

  if [[ "$expect_empty" == "true" ]]; then
    if [[ -n "${out//[[:space:]]/}" && "$out" != "None" && "$out" != "null" && "$out" != "[]" ]]; then
      echo "   FOUND (potential cost):"
      echo "$out"
      failures=$((failures + 1))
    else
      echo "   OK: none found"
    fi
  else
    echo "$out"
  fi
}

echo "Cost Safety Check"
echo "  AWS_PROFILE=$AWS_PROFILE"
echo "  AWS_REGION=$AWS_REGION"
echo "  Tag filter: $PROJECT_TAG_KEY=$PROJECT_TAG_VALUE"
echo "  STRICT_EKS=$STRICT_EKS"

# 1) EKS clusters
section "EKS"
if [[ "$STRICT_EKS" == "true" ]]; then
  check "EKS clusters in region" \
    "aws_cli eks list-clusters --query 'clusters' --output json" \
    "true"
else
  # Best-effort: list clusters then describe tags, filter by tag.
  echo
  echo "-> EKS clusters tagged with $PROJECT_TAG_KEY=$PROJECT_TAG_VALUE"
  clusters_json=$(aws_cli eks list-clusters --query 'clusters' --output json)
  if [[ "$clusters_json" == "[]" ]]; then
    echo "   OK: no clusters in region"
  else
    matched=()
    # crude JSON parse without jq: iterate by line
    for c in $(echo "$clusters_json" | tr -d '[]",' ); do
      arn=$(aws_cli eks describe-cluster --name "$c" --query 'cluster.arn' --output text 2>/dev/null || true)
      if [[ -n "$arn" && "$arn" != "None" ]]; then
        val=$(aws_cli eks list-tags-for-resource --resource-arn "$arn" --query "tags.\"$PROJECT_TAG_KEY\"" --output text 2>/dev/null || true)
        if [[ "$val" == "$PROJECT_TAG_VALUE" ]]; then
          matched+=("$c")
        fi
      fi
    done
    if [[ ${#matched[@]} -gt 0 ]]; then
      echo "   FOUND (clusters): ${matched[*]}"
      failures=$((failures + 1))
    else
      echo "   OK: no matching tagged clusters"
    fi
  fi
fi

# 2) EC2 instances (running) with project tag
section "EC2"
check "Running EC2 instances with $PROJECT_TAG_KEY=$PROJECT_TAG_VALUE" \
  "aws_cli ec2 describe-instances \
    --filters Name=instance-state-name,Values=running Name=tag:$PROJECT_TAG_KEY,Values=$PROJECT_TAG_VALUE \
    --query 'Reservations[].Instances[].{Id:InstanceId,Type:InstanceType,AZ:Placement.AvailabilityZone,PrivIP:PrivateIpAddress}' \
    --output table" \
  "true"

# 3) Load balancers (ALB/NLB)
section "Load Balancers"
# Note: ELBv2 doesn't always carry your Project tag depending on controller behavior.
# This is intentionally broad; if you use other LBs in the account, you can filter later.
check "ELBv2 load balancers in region (ALB/NLB)" \
  "aws_cli elbv2 describe-load-balancers \
    --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code,DNS:DNSName}' \
    --output table" \
  "true"

# 4) NAT Gateways (expensive)
section "NAT Gateways"
check "NAT Gateways (available or pending)" \
  "aws_cli ec2 describe-nat-gateways \
    --filter Name=state,Values=available,pending \
    --query 'NatGateways[].{Id:NatGatewayId,State:State,Subnet:SubnetId,PublicIP:NatGatewayAddresses[0].PublicIp}' \
    --output table" \
  "true"

# 5) Unattached EBS volumes (often left behind)
section "EBS Volumes"
check "Unattached EBS volumes (state=available)" \
  "aws_cli ec2 describe-volumes \
    --filters Name=status,Values=available \
    --query 'Volumes[].{Id:VolumeId,Size:Size,Type:VolumeType,AZ:AvailabilityZone,CreateTime:CreateTime}' \
    --output table" \
  "true"

# 6) Elastic IPs (unassociated EIPs can cost)
section "Elastic IPs"
check "Unassociated Elastic IPs" \
  "aws_cli ec2 describe-addresses \
    --query 'Addresses[?AssociationId==null].{PublicIp:PublicIp,AllocationId:AllocationId,Domain:Domain}' \
    --output table" \
  "true"

section "Summary"
if [[ $failures -gt 0 ]]; then
  echo "FAIL: Potential cost-incurring resources detected. Count=$failures"
  echo "Action: destroy/cleanup the above resources before ending the day."
  exit 2
else
  echo "PASS: No obvious cost-incurring resources detected."
fi
