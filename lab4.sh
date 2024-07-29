#!/bin/bash
#!/bin/bash

# Function to deploy Blue version
deploy_blue() {
  echo "Deploying Blue version..."
  microk8s kubectl apply -f spark-k8s-deployment/spark-master-blue-deployment.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-worker-blue-deployment.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-master-service.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-ingress.yaml
}

# Function to deploy Green version
deploy_green() {
  echo "Deploying Green version..."
  microk8s kubectl apply -f spark-k8s-deployment/spark-master-green-deployment.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-worker-green-deployment.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-master-service.yaml
  microk8s kubectl apply -f spark-k8s-deployment/spark-ingress.yaml
}

# Function to clean up the environment
clean_up() {
  echo "Cleaning up the environment..."
  microk8s kubectl delete deployments --all
  microk8s kubectl delete services --all
  microk8s kubectl delete ingress spark-ingress
}

# Check command line arguments and execute corresponding function
if [ "$1" == "blue" ]; then
  deploy_blue
elif [ "$1" == "green" ]; then
  deploy_green
elif [ "$1" == "clean" ]; then
  clean_up
else
  echo "Usage: $0 {blue|green|clean}"
  exit 1
fi
