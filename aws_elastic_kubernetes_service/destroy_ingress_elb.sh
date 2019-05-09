#!/usr/bin/env bash

set -e
#set -x
set -o pipefail

LB_NAME=$1

# find the ENIs associated with this ELB
INTERFACES=$(aws ec2 describe-network-interfaces \
  --filter "Name=description,Values=ELB ${LB_NAME}" \
  --query 'NetworkInterfaces'
)

# parse out the ENI IDs
# shellcheck disable=SC2207
ENI_IDS=($(echo "$INTERFACES" \
  | jq -r '.[].NetworkInterfaceId'
))

# parse out the security group(s)
# shellcheck disable=SC2207
SECURITY_GROUPS=($(echo "$INTERFACES" \
  | jq -r '.[].Groups[].GroupId' \
  | sort | uniq
))

# delete the ingress ELB and wait for it to disappear
aws elb delete-load-balancer --load-balancer-name "$LB_NAME"
while aws elb describe-load-balancers --load-balancer-names "$LB_NAME" &>/dev/null; do
  # wait for load balancer to be deleted
  sleep 3
done

# seek out associated elastic network interfaces and delete them
if [ ${#ENI_IDS[@]} -gt 0 ]; then
  for ENI_ID in "${ENI_IDS[@]}"; do
    # keep trying to delete until we succeed
    while aws ec2 describe-network-interfaces --network-interface-id "$ENI_ID" &>/dev/null; do
      aws ec2 delete-network-interface --network-interface-id "$ENI_ID" &>/dev/null || true;
      sleep 3
    done
  done
fi

# the ingress ELB security group gets included in the main k8s security group,
# (and potentially others).  This finds any security groups referencing this
# group and removes the references before deleting the group.
if [ ${#SECURITY_GROUPS[@]} -gt 0 ]; then
  for GID in "${SECURITY_GROUPS[@]}"; do
    # shellcheck disable=SC2207
    REF_GROUPS=($(aws ec2 describe-security-groups \
      --filter "Name=ip-permission.group-id,Values=$GID" \
      | jq -r '.SecurityGroups[].GroupId'
    ))
    for RGID in "${REF_GROUPS[@]}"; do
      aws ec2 revoke-security-group-ingress \
        --group-id "$RGID" \
        --source-group "$GID" \
        --protocol all \
        --port "0-65535"
    done

    while ! aws ec2 delete-security-group --group-id "$GID" &>/dev/null; do
      sleep 3
    done
  done
fi
