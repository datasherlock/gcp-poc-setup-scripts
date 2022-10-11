#! /bin/bash

source config.sh

############################## Validation ####################################
[[ -z $1 ]] && echo "Enter source path..." && exit 1 || SOURCE_PATH=$1
[[ -z $2 ]] && echo "Enter cluster name. Exiting..." && exit 1 || CLUSTER_NAME=$2
[[ ! -z $PROPERTIES ]] && PROPERTIES_STRING="--properties=[${PROPERTIES}]"  
################################################################################

echo "Executing the command \n
time gcloud dataproc jobs submit hadoop \
--class org.apache.hadoop.examples.terasort.TeraGen \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
${PROPERTIES_STRING} \
-- ${SOURCE_PATH} gs://${GCS_BUCKET}/${TGT_TERSORT_PATH}/"

time gcloud dataproc jobs submit hadoop \
--class org.apache.hadoop.examples.terasort.TeraSort \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
${PROPERTIES_STRING} \
-- ${SOURCE_PATH} gs://${GCS_BUCKET}/${TGT_TERASORT_PATH}/										