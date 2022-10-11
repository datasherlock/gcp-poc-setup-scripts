#! /bin/bash

source config.sh

# Create bucket if it doesn't exist
gsutil ls -b gs://${GCS_BUCKET} || gsutil mb gs://${GCS_BUCKET}

############################## Validation ####################################
[[ -z $1 ]] && echo "Enter number of rows. Exiting..." && exit 1 || ROWS=$1
[[ -z $2 ]] && echo "Enter cluster name. Exiting..." && exit 1 || CLUSTER_NAME=$2
[[ ! -z $PROPERTIES ]] && PROPERTIES_STRING="--properties=[${PROPERTIES}]"  
################################################################################

echo "Executing the command \n
time gcloud dataproc jobs submit hadoop \
--class org.apache.hadoop.examples.terasort.TeraGen \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
${PROPERTIES_STRING} \
-- ${ROWS} gs://${GCS_BUCKET}/${TGT_TERAGEN_PATH}/"

time gcloud dataproc jobs submit hadoop \
--class org.apache.hadoop.examples.terasort.TeraGen \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
${PROPERTIES_STRING} \
-- ${ROWS} gs://${GCS_BUCKET}/${TGT_TERAGEN_PATH}/										