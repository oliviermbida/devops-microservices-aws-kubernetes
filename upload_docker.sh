#!/usr/bin/env bash
# This file tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`
# Install dependencies
sudo apt install -y jq 
# REPO_EXIST=$(aws ecr describe-repositories --output text --query "repositories[].repositoryName" | grep -oh "ai-cloudsolutions")
# if [ $REPO_EXIST != "ai-cloudsolutions" ]; then \
#     aws ecr create-repository \
#         --repository-name ai-cloudsolutions \
# fi
# Get AWS details
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION=$(aws configure get region)
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
echo "Docker ID and Image: $dockerpath"
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin 
docker build --tag "$dockerpath:latest" .
docker image ls
# Step 3:
# Push image to a docker repository
docker push "$dockerpath:latest"
#Push image to AWS ECR
docker tag "$dockerpath:latest" $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-cloudsolutions:flask-app-prediction
docker image ls
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-cloudsolutions:flask-app-prediction
