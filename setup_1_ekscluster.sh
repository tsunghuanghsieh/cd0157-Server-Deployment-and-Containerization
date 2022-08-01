#!/bin/zsh

#
# This will create EKS cluster for the project, and update configmap with role created in set_3_iarole.sh.
#

. "`dirname $0`/sh_common.sh"
. "`dirname $0`/setup_common.sh"

AwsBinary=`which aws`
if [ ! -f $AwsBinary ]; then
    echo -e $MSG_ERROR_PREFIX 1>&2
    echo -e $MSG_ERROR_PREFIX aws is not installed on the system... 1>&2
    echo -e $MSG_ERROR_PREFIX 1>&2
    exit 1
fi

# eksctl binary version 0.106.0
EksctlBinary=`which eksctl`

if [ ! -f $EksctlBinary ]; then
    echo -e $MSG_ERROR_PREFIX 1>&2
    echo -e $MSG_ERROR_PREFIX eksctl is not installed on the system... 1>&2
    echo -e $MSG_ERROR_PREFIX 1>&2
    exit 1
fi

KubeCtlBinary=`which kubectl`
if [ ! -f $KubeCtlBinary ]; then
    echo -e $MSG_ERROR_PREFIX 1>&2
    echo -e $MSG_ERROR_PREFIX kubectl is not installed on the system... 1>&2
    echo -e $MSG_ERROR_PREFIX 1>&2
    exit 1
fi

# Create EKS clusster
eksctl create cluster --name $ClusterName --region=us-east-2 --profile $ProfileName

# Get current configmap of the cluster
$KubeCtlBinary get -n kube-system configmap/aws-auth -o yaml > $ConfigmapFile


# Get AWS account ID
Account_Id=`aws sts get-caller-identity --query Account --output text`

# Add IAM role for CodeBuild service to the configmap
"`dirname $0`/update_configmap.py" $Account_Id

# Update cluster's configmap
$KubeCtlBinary patch configmap/aws-auth -n kube-system --patch "$(cat $ConfigmapFile)"

# Docker container deployement
# $KubeCtlBinary apply -f $DockerDeploymentConfigFile