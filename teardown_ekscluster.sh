#!/bin/zsh

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

#
$KubeCtlBinary delete deployments/$DockerDeployementName

# Alternatively, delete EKS cluster from CloudFormation console, not from EKS Console, to avoid dangling resources
eksctl delete cluster $ClusterName
