# Base image
FROM openjdk:11

# Define Spark and Hadoop versions
ENV SPARK_VERSION=3.2.0
ENV HADOOP_VERSION=3.3.1

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Create directories for Spark and Hadoop
RUN mkdir -p /opt/spark /opt/hadoop

# Copy downloaded files into the Docker image
COPY hadoop-3.3.1.tar.gz /opt/hadoop/
COPY spark-3.2.0-bin-hadoop2.7.tgz /opt/spark/

# Extract Hadoop
RUN cd /opt/hadoop && \
    tar -zxvf hadoop-3.3.1.tar.gz --strip-components=1 && \
    ln -s /opt/hadoop /opt/hadoop-current && \
    echo Hadoop ${HADOOP_VERSION} installed in /opt/hadoop

# Extract Spark
RUN cd /opt/spark && \
    tar -zxvf spark-3.2.0-bin-hadoop2.7.tgz --strip-components=1 && \
    ln -s /opt/spark /opt/spark-current && \
    echo Spark ${SPARK_VERSION} installed in /opt/spark

# Add custom scripts and configuration
COPY common.sh spark-master spark-worker /opt/
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Make scripts executable
RUN chmod +x /opt/common.sh /opt/spark-master /opt/spark-worker

# Set environment variables
ENV PATH=$PATH:/opt/spark/bin

# Default command
#CMD ["/bin/bash"]
