#! /bin/bash

source config.sh

# Create bucket if it doesn't exist
gsutil ls -b gs://${GCS_BUCKET} || gsutil mb gs://${GCS_BUCKET}

############################## Validation ####################################
[[ -z $1 ]] && echo "Enter number of maps" && exit 1 || MAPS=$1
[[ -z $2 ]] && echo "Enter number of samples" && exit 1 || SAMPLES=$2
[[ -z $3 ]] && echo "Enter cluster name. Exiting..." && exit 1 || CLUSTER_NAME=$3
[[ ! -z $PROPERTIES ]] && PROPERTIES_STRING="--properties=[${PROPERTIES}]"  
################################################################################

echo "Executing the command \n
time gcloud dataproc jobs submit hadoop \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
--jar=file:///usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar \
-- pi ${MAPS} ${SAMPLES} "

time gcloud dataproc jobs submit hadoop \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
--jar=file:///usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar \
-- pi ${MAPS} ${SAMPLES}								