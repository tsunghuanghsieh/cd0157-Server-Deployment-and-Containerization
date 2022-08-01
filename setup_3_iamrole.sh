#!/bin/zsh

#
# This will create a role and add policy (iam-role-policy.json) to the role.
#

# Get AWS account ID
Account_Id=`aws sts get-caller-identity --query Account --output text`

# Update trust relationship in trust.json
"`dirname $0`/update_trust.py" $Account_Id

PolicyName="eks-describe"
RoleName="UdacityFlaskDeployCBKubectlRole"

if [ -z "aws iam get-role --role-name $RoleName" ]; then
    aws iam create-role \
        --role-name $RoleName \
        --assume-role-policy-document file://trust.json \
        --output text \
        --query 'Role.Arn'
fi

# Add inline Policy to the role
aws iam put-role-policy \
    --role-name $RoleName \
    --policy-name $PolicyName \
    --policy-document file://iam-role-policy.json