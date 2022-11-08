#! /bin/bash

source config.sh

# Create bucket if it doesn't exist
gsutil ls -b gs://${GCS_BUCKET} || gsutil mb gs://${GCS_BUCKET}

############################## Validation ####################################
[[ -z $1 ]] && echo "Enter number of tasks" && exit 1 || TASKS=$1
[[ -z $2 ]] && echo "Enter cluster name. Exiting..." && exit 1 || CLUSTER_NAME=$2
[[ ! -z $PROPERTIES ]] && PROPERTIES_STRING="--properties=[${PROPERTIES}]"  
################################################################################

echo "Executing the command \n
time gcloud dataproc jobs submit spark \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
--jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
--class="org.apache.spark.examples.SparkPi" \
-- ${TASKS} "

time gcloud dataproc jobs submit spark \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
--jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
--class="org.apache.spark.examples.SparkPi" \
-- ${TASKS}