#!/usr/bin/env bash
# This file tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`
# Install dependencies
sudo apt install -y jq 
# ECR repo
AWS_ECR_REPO=ai-cloudsolutions
# Get AWS details
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION=$(aws configure get region)
AWS_ECR_ACCOUNT_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
# Get dockerhub credentials from aws secretsmanager
DOCKERHUB_USERNAME=$(aws ssm get-parameter \
    --name /aws/reference/secretsmanager/dockerhub \
    --with-decryption --output text --query "Parameter.Value" | jq -r ."username")
DOCKERHUB_PASSWORD=$(aws ssm get-parameter \
    --name /aws/reference/secretsmanager/dockerhub \
    --with-decryption --output text --query "Parameter.Value" | jq -r ."password")
# Configure credentials store
#./docker-cred.sh
# Step 1:
# Create dockerpath
# dockerpath=<your docker ID/path>
dockerpath=$(printf "%s/%s" "${DOCKERHUB_USERNAME}" "flask-app-prediction")
# Step 2:  
# Authenticate & tag
echo "Docker ID and Image: ${dockerpath}"
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin 
docker build --tag "$dockerpath:latest" .
docker image ls
# Step 3:
# Push image to a docker repository
docker push "${dockerpath}:latest"
#Push image to AWS ECR private repository
aws ecr describe-repositories --region "${AWS_REGION}" --repository-names "${AWS_ECR_REPO}" >/dev/null 2>&1 || \
    aws ecr create-repository --region "${AWS_REGION}" --repository-name "${AWS_ECR_REPO}" 
# ECR public
# aws ecr-public describe-repositories --region "${AWS_REGION}" --repository-names "${ECR_REPO}" >/dev/null 2>&1 || \
#     aws ecr-public create-repository --region "${AWS_REGION}" --repository-name "${ECR_REPO}" 
    
docker tag "${dockerpath}:latest" "${AWS_ECR_ACCOUNT_URL}/${AWS_ECR_REPO}:flask-app-prediction"
docker image ls
if cat ~/.docker/config.json | grep "${AWS_ECR_ACCOUNT_URL}" > /dev/null 2>&1 ; then 
    echo "ECR credential helper is already installed" 
else 
    aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ECR_ACCOUNT_URL}" 
fi
docker push "${AWS_ECR_ACCOUNT_URL}/${AWS_ECR_REPO}:flask-app-prediction"
