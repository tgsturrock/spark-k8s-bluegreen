
# **Implementing an Apache Spark Cluster on Kubernetes with a Blue/Green Strategy**

## **Project Overview**

This project focuses on deploying and managing an **Apache Spark** cluster on **Kubernetes** using a **Blue/Green deployment strategy**. The goal is to provide a highly available and fault-tolerant system for big data processing, while also demonstrating how to update a service seamlessly without downtime.

The lab involves:

  * Building two distinct Docker images for **Apache Spark versions 3.2.0** (the "Blue" version) and **3.2.1** (the "Green" version).
  * **Automating the deployment** of a Spark cluster on a Kubernetes environment.
  * **Orchestrating a Blue/Green update**, where a new version of the service (Green) is deployed alongside the old version (Blue).
  * **Switching traffic** from the old service to the new one in a controlled manner.
  * **Cleaning up** the old version once the transition is complete and validated.

This approach ensures service continuity and a smooth user experience, which is critical for time-sensitive big data operations.

-----

## **Directory Structure**

The repository contains the following directories and files:

  * **spark3.2.0**: Contains the necessary files to build the Docker image for Spark 3.2.0.
  * **spark3.2.1**: Contains the necessary files to build the Docker image for Spark 3.2.1.
  * **spark-master-deployment.yaml**: Kubernetes YAML file for deploying the Spark Master node.
  * **spark-worker-deployment.yaml**: Kubernetes YAML file for deploying the Spark Worker nodes.
  * **spark-master-service.yaml**: Kubernetes YAML file for creating a service to expose the Spark Master.
  * **spark-ingress.yaml**: Kubernetes YAML file for configuring an Ingress to provide external access to the Spark web UI.
  * **lab4.sh**: The main script to automate the entire deployment and Blue/Green update process.

Each of the `spark3.2.x` directories includes:

  * **Dockerfile**: The instructions for building the Spark image.
  * **spark-defaults.conf**: The default configuration for Spark.
  * **spark-master** and **spark-worker** scripts to start the respective nodes.
  * **apache-hadoop-3.3.1** and **apache-spark-3.2.x** archives.

-----

## **The `lab4.sh` Automation Script**

The `lab4.sh` script is the core of this project, automating the entire Blue/Green deployment lifecycle on a Kubernetes cluster.

**Core functionalities of the script include:**

1.  **Deployment**: It first builds the **spark:3.2.0** (Blue) Docker image and applies the Kubernetes YAML files to deploy the initial Spark Master and two Worker replicas.
2.  **Validation**: It performs checks to confirm that the Kubernetes deployments and services are running as expected. It then executes a simple **Spark job** (e.g., a word count on a short text) to validate that the Blue cluster is functional.
3.  **Blue/Green Transition**: The script then builds the new **spark:3.2.1** (Green) image. It deploys the Green version alongside the Blue one and updates the service to redirect traffic to the new Green version.
4.  **Cleanup**: Once the transition is successful, the script deletes the Blue version's deployments and services to free up resources.
5.  **Final Validation**: It runs the same test Spark job on the new Green version to ensure the update was successful.
6.  **Environment Cleanup**: Finally, the script removes all Kubernetes resources, leaving the environment in a clean state.

This script demonstrates a robust, automated approach to updating critical services, ensuring a seamless and reliable transition from one version to the next.

-----

## How to use the `lab4.sh` file

Before running the script, ensure you have a functional Kubernetes cluster (e.g., Microk8s) with at least two nodes configured. The `lab4.sh` script assumes you have `docker` and `kubectl` installed and configured correctly.

  * To run the script and execute the full Blue/Green deployment cycle, simply use:

<!-- end list -->

```bash
./lab4.sh
```

  * To clean the environment, the script includes a cleanup routine that removes all deployed services and resources.
