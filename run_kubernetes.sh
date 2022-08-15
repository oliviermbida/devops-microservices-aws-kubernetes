#!/usr/bin/env bash

#minikube start --container-runtime=docker
# Get dockerhub credentials from aws secretsmanager
DOCKERHUB_USERNAME=$(aws ssm get-parameter \
    --name /aws/reference/secretsmanager/dockerhub \
    --with-decryption --output text --query "Parameter.Value" | jq -r ."username")
DOCKERHUB_PASSWORD=$(aws ssm get-parameter \
    --name /aws/reference/secretsmanager/dockerhub \
    --with-decryption --output text --query "Parameter.Value" | jq -r ."password")
if cat ~/.docker/config.json | grep "https://index.docker.io/v1/" > /dev/null 2>&1 ; then
    echo "Docker credential helper is already installed"
else
    echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
fi    
# This tags and uploads an image to Docker Hub

# Step 1:
# This is your Docker ID/path
# dockerpath=<>
dockerpath="docker.io/uavsystems/flask-app-prediction"

echo "Docker ID and Image: ${dockerpath}"

# Step 2
# Run the Docker Hub container with kubernetes
#kubectl run minikube-flask-app-prediction --image="${dockerpath}
echo "---Apply deployment---"
kubectl apply -f app-deployment.yml
# kubectl rollout status deployment/flask-app-prediction | grep -oh "successfully rolled out"
echo "---Review deployments---"
kubectl describe deployments
echo "--Apply service--"
kubectl apply -f app-service.yml
# Step 3:
# List kubernetes pods
#kubectl get pod minikube-flask-app-prediction 
echo "---Get pods---"
kubectl get pods --show-labels
echo "---Get deployment---"
kubectl get deployment
echo "Get services---"
kubectl get service
# Step 4:
# Forward the container port to a host
#kubectl port-forward minikube-flask-app-prediction  8000:80

while [ 1 ]   # Endless loop.
do
    podstaus=$(kubectl get pods  -o json | jq -r ".items[].status.phase")
    echo "Pod Status: $podstaus"
    if [[ $podstaus == "Running"  ]]; then
        echo "Exiting pod status: $podstaus"
        break;
    fi
    sleep 5
done
kubectl get pods --show-labels 
echo "---Forwarding local port---"
kubectl port-forward service/flask-app-prediction 8000:80



