# devops-microservices-aws-kubernetes [![CircleCI](https://dl.circleci.com/status-badge/img/gh/oliviermbida/devops-microservices-aws-kubernetes/tree/master.svg?style=svg&circle-token=ccac6deceb852f5f0b86453f19cc870a2b6669a6)](https://dl.circleci.com/status-badge/redirect/gh/oliviermbida/devops-microservices-aws-kubernetes/tree/master)

DevOps Microservices at Scale using AWS &amp; Kubernetes.

Operationalize a Machine Learning Microservice API.

Given a pre-trained, sklearn model that has been trained to predict housing prices in Boston according to several features,

such as average rooms in a home and data about highway access, teacher-to-pupil ratios.

This project operationalize a Python flask app in a provided file, `app.py`

that serves out predictions (inference) about housing prices through API calls. 

# Solution Details

-------------------

# Local Docker deployment (for local tests):

. `run_docker.sh` 

This will build a Docker image and runs the app locally in a Docker container.

. `make_prediction.sh` 

Run in another terminal to make a prediction.

# AWS ECS deployment:

. `upload_docker.sh` 

This will registers the app image on Dockerhub and AWS ECR.

. `ecs-deploy.sh`

This will retrieve the AWS ECR image and deploy to AWS ECS clusters and create a service accessible via an elastic load balancer.
    
. `ecs.yaml` 

Contains the details of the AWS infrastructure created.

You can scale your clusters using the `DesiredCapacity`  and `MaxSize` parameters or use the pre-defined `ServiceScalingPolicy`.

You must specify the following parameter: ECR image created and at least two subnets in your pre-existing VPC.

Ensure that the AWS infrastructure is deleted so that you do not incurred additional costs.
    
. `make_prediction_ecs.sh` 

Make a prediction using the running ecs service. You must specify the dns of the elastic load balancer

# Local Kubernetes deployment (for local tests):

. Pre-requisites: Install minikube and kubectl

. It uses the local Docker image from the step above

. `run_kubernetes.sh`

This will deploy a kubernetes cluster and apply a service locally 

. `make_prediction.sh` 

Run in another terminal to make a prediction using the kubernetes service.

# CircleCI Pipeline for automated deployment:

. `circleci/config.yml`

Contains the workflow for deployment to AWS ECS

. build job : 

Will run the linter

. deploy-app job : 

Will register the app image on Dockerhub and AWS ECR. 

Then deploy to AWS ECS clusters and create a service accessible via a public elastic load balancer.

# Miscelleneous:

To run the Linter for Dockerfile, python and cloudformation files 

. Prerequisite: Install CircleCI CLI

. `make run-circleci-local` 

This will run the build job found in .circleci/config.yml

Alternatively

. `make lint`

This will run in the isolated environment created with `make setup`

![Linter](docs/images/linter.png)

