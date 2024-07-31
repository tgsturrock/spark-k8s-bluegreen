#!/bin/bash

set -e

# Define paths to YAML files
BLUE_MASTER_DEPLOYMENT="spark-master-deployment-blue.yaml"
BLUE_WORKER_DEPLOYMENT="spark-worker-deployment-blue.yaml"
GREEN_MASTER_DEPLOYMENT="spark-master-deployment-green.yaml"
GREEN_WORKER_DEPLOYMENT="spark-worker-deployment-green.yaml"
SERVICE_YAML="spark-master-service.yaml"
INGRESS_YAML="spark-ingress.yaml"

# Function to validate a deployment
validate_deployment() {
  local deployment_name=$1
  local replicas=$2
  local timeout=${3:-300}  # default timeout is 300 seconds

  echo "Validating deployment ${deployment_name}..."
  end=$((SECONDS + timeout))

  while true; do
    available_replicas=$(microk8s kubectl get deployment "${deployment_name}" -o jsonpath='{.status.availableReplicas}')
    if [ "${available_replicas}" == "${replicas}" ]; then
      echo "Deployment ${deployment_name} is successfully rolled out."
      break
    fi
    if [ ${SECONDS} -ge ${end} ]; then
      echo "Deployment ${deployment_name} validation failed."
      exit 1
    fi
    sleep 5
  done
}

# Function to validate a service
validate_service() {
  local service_name=$1
  local timeout=${2:-300}  # default timeout is 300 seconds

  echo "Validating service ${service_name}..."
  end=$((SECONDS + timeout))

  while true; do
    endpoints=$(microk8s kubectl get endpoints "${service_name}" -o jsonpath='{.subsets[*].addresses[*].ip}')
    if [ -n "${endpoints}" ]; then
      echo "Service ${service_name} is successfully set up."
      break
    fi
    if [ ${SECONDS} -ge ${end} ]; then
      echo "Service ${service_name} validation failed."
      exit 1
    fi
    sleep 5
  done
}

# Function to validate Spark job
validate_spark_job() {
  local master_pod=$1
  local master_ip=$2

  echo "Validating Spark job on master pod ${master_pod}..."

  # Define the Spark job script
  local spark_job_script=$(cat <<'EOF'
from pyspark import SparkContext

words = 'the quick brown fox jumps over the lazy dog the quick brown fox jumps over the lazy dog'
sc = SparkContext.getOrCreate()
seq = words.split()
data = sc.parallelize(seq)
counts = data.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).collect()
print(dict(counts))
sc.stop()
EOF
)

  # Execute the Spark job
  microk8s kubectl exec "${master_pod}" -it -- pyspark --conf spark.driver.bindAddress="${master_ip}" --conf spark.driver.host="${master_ip}" <<EOF
${spark_job_script}
EOF

  echo "Spark job executed successfully."
}

# Deploy Blue version
echo "Deploying Blue version..."
microk8s kubectl apply -f "${BLUE_MASTER_DEPLOYMENT}"
microk8s kubectl apply -f "${BLUE_WORKER_DEPLOYMENT}"
microk8s kubectl apply -f "${SERVICE_YAML}"
microk8s kubectl apply -f "${INGRESS_YAML}"

# Validate Blue deployments
validate_deployment "spark-master-blue" 1
validate_deployment "spark-worker-blue" 2

# Validate service
validate_service "spark-master"

#Wait for deployment to settle
sleep 2

# Identify the Spark Master pod and IP
master_pod=$(microk8s kubectl get pods -l app=spark,role=master,version=blue -o jsonpath='{.items[0].metadata.name}')
master_ip=$(microk8s kubectl get pod "${master_pod}" -o jsonpath='{.status.podIP}')

echo "------------"
# Validate Spark job
validate_spark_job "${master_pod}" "${master_ip}"
echo "------------"

# Deploy Green version
echo "Deploying Green version..."
microk8s kubectl apply -f "${GREEN_MASTER_DEPLOYMENT}"
microk8s kubectl apply -f "${GREEN_WORKER_DEPLOYMENT}"

# Validate Green deployments
validate_deployment "spark-master-green" 1
validate_deployment "spark-worker-green" 2

# Switch service to Green version
echo "Switching service to Green version..."
microk8s kubectl patch service spark-master -p '{"spec":{"selector":{"version":"green"}}}'

# Validate service is now pointing to Green version
validate_service "spark-master"

# Clean up Blue version
echo "Cleaning up Blue version..."
microk8s kubectl delete -f "${BLUE_MASTER_DEPLOYMENT}"
microk8s kubectl delete -f "${BLUE_WORKER_DEPLOYMENT}"
echo "------------"


#Wait for deployment to settle and transition to green
sleep 15

# Identify the Spark Master pod and IP
master_pod=$(microk8s kubectl get pods -l app=spark,role=master,version=green -o jsonpath='{.items[0].metadata.name}')
master_ip=$(microk8s kubectl get pod "${master_pod}" -o jsonpath='{.status.podIP}')


# Validate Spark job
validate_spark_job "${master_pod}" "${master_ip}"

echo "Deployment completed successfully."
echo "------------"

# Clean up
echo "Cleaning up enviroment..."
microk8s kubectl delete -f spark-master-deployment-green.yaml
microk8s kubectl delete -f spark-worker-deployment-green.yaml

# Clean up the Spark service
microk8s kubectl delete service spark-master

# Clean up the Ingress
microk8s kubectl delete ingress spark-ingress

echo "Environment cleaned up successfully."
