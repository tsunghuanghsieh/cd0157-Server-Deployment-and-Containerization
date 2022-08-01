# EKS cluster name
ClusterName="simple-jwt-api"
# EKS cluster configmap filename
ConfigmapFile="aws-auth-patch.yaml"
# In file specified by DockerDeploymentConfigFile, value of metadata.name
DockerDeployementName="simple-jwt-api"
# EKS docker deployment config filename
DockerDeploymentConfigFile="deplyment.yaml"
# Change profile name if you don't want to use your AWS default profile
ProfileName="default"
# Deployment template filename
PipelineTemplateFile="ci-cd-codepipeline.cfn.yml"
# CloudFormation stack name for deployment
StackName="simple-jwt-api"
