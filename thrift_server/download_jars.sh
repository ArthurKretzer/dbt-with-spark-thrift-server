#!/bin/bash

# Define the list of packages
packages=(
    "ch.cern.sparkmeasure:spark-measure_2.12:0.24"
    "org.apache.hadoop:hadoop-client-api:3.3.4"
    "org.apache.hadoop:hadoop-client-runtime:3.3.4"
    "io.delta:delta-spark_2.12:3.2.0"
    "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.8.1"
    "org.apache.hadoop:hadoop-aws:3.3.4"
    "com.amazonaws:aws-java-sdk-bundle:1.12.262"
    "org.apache.hadoop:hadoop-common:3.3.4"
    "org.apache.hadoop:hadoop-hdfs-client:3.3.4"
    "org.apache.hadoop:hadoop-auth:3.3.4"
    "org.apache.hadoop:hadoop-annotations:3.3.4"
)

# Loop through each package and run Spark Shell to download dependencies
for package in "${packages[@]}"; do
    echo "Installing package: $package"
    /opt/spark/bin/spark-shell --conf spark.jars.repositories=https://repo1.maven.org/maven2,https://repo.maven.apache.org/maven2 --packages "$package" --verbose <<< "exit"
done

echo "All packages installed."