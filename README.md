# devops-microservices-aws-kubernetes  
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/oliviermbida/devops-microservices-aws-kubernetes/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/oliviermbida/devops-microservices-aws-kubernetes/tree/master)

DevOps Microservices at Scale using AWS &amp; Kubernetes 

# Solution Preview

Local Docker deployment (for local tests):
. run_docker.sh : This will build a Docker image and runs the Docker image locally 
. make_prediction.sh : Run in another terminal to make a prediction.

AWS ECS deployment:
. upload_docker.sh : This will registers the image on Dockerhub and AWS ECR.
. ecs-deploy.sh : 
    This will deploy to AWS ECS clusters and create a service accessible via an elastic load balancer.
. ecs.yaml : Contains the details of the AWS infrastructure created.
    You must specify the following parameter: ECR image created, your EC2 keypair name and at least two subnets in your pre-existing VPC.
    Ensure that the AWS infrastructure is deleted so that you do not incurred additional costs.
. make_prediction_ecs.sh : Make a prediction using the running ecs service.

Local Kubernetes deployment (for local tests):
. Pre-requisites: Install minikube and kubectl
. It uses the local Docker image from the step above
. run_kubernetes.sh : This will deploy a kubernetes cluster and apply a service locally 
. make_prediction.sh : Run in another terminal to make a prediction using the kubernetes service.

