# !/bin/bash

# Creates a Dataproc cluster using an Autoscaling policy and a managed metastore for Hive.
# Modify configurations as needed. It assumes all configurations are stored under a bucket that is named using the project_id

####################################################### CONFIGURATIONS START ###############################################################
echo "Getting project configurations..."
source PROJECT_IAM_CONFIG.sh
echo "Getting cluster configurations..."
source CLUSTER_CONFIG.sh 

####################################################### CONFIGURATIONS END ###############################################################

####################################################### VALIDATIONS START ###############################################################

[[ -z "$DATAPROC_PROPERTIES" ]] && PROPERTIES_STRING="" || PROPERTIES_STRING="--properties ${DATAPROC_PROPERTIES}"
[[ -z "$DATAPROC_METASTORE" ]] && DPMS_STRING="" || DPMS_STRING="--dataproc-metastore projects/${PROJECT}/locations/${REGION}/services/${DATAPROC_METASTORE}"
[[ -z "$DATAPROC_SCALING_POLICY" ]] && SCALING_POLICY_STRING="" || SCALING_POLICY_STRING="--autoscaling-policy ${DATAPROC_SCALING_POLICY}"
[[ -z "$DATAPROC_INITIALISATION_SCRIPTS" ]] && INIT_STRING="" || INIT_STRING="--initialization-actions ${DATAPROC_INITIALISATION_SCRIPTS}"
[[ -z "$DATAPROC_OPTIONAL_COMPONENTS" ]] && OPT_COMP_STRING="" || OPT_COMP_STRING="--optional-components ${DATAPROC_OPTIONAL_COMPONENTS}"
[[ -z $1 ]] && CLUSTER_NAME='poc-cluster-'$(uuidgen) || CLUSTER_NAME=$1

####################################################### VALIDATIONS END ###############################################################
echo "Creating cluster using the command - "
echo "
gcloud dataproc clusters create ${CLUSTER_NAME} \
--enable-component-gateway \
--region $REGION \
--subnet default \
--zone $ZONE \
--master-machine-type ${WORKER_MACHINE_TYPE} \
--master-boot-disk-size ${MASTER_BOOT_DISK_GB} \
--num-master-local-ssds ${MASTER_LOCAL_SSD_NUM} \
--num-workers ${WORKER_PRIMARY_CNT} \
--worker-machine-type ${WORKER_MACHINE_TYPE} \
--worker-boot-disk-size ${WORKER_BOOT_DISK} \
--num-worker-local-ssds ${WORKER_LOCAL_SSD_NUM} \
--image-version ${DATAPROC_IMAGE_VERSION} \
--service-account=${SERVICE_ACCOUNT} \
--project $PROJECT \
${OPT_COMP_STRING} \
${SCALING_POLICY_STRING} \
${PROPERTIES_STRING} \
${DPMS_STRING} \
${INIT_STRING}"

gcloud dataproc clusters create ${CLUSTER_NAME} \
--enable-component-gateway \
--region $REGION \
--subnet default \
--zone $ZONE \
--master-machine-type ${WORKER_MACHINE_TYPE} \
--master-boot-disk-size ${MASTER_BOOT_DISK_GB} \
--num-master-local-ssds ${MASTER_LOCAL_SSD_NUM} \
--num-workers ${WORKER_PRIMARY_CNT} \
--worker-machine-type ${WORKER_MACHINE_TYPE} \
--worker-boot-disk-size ${WORKER_BOOT_DISK} \
--num-worker-local-ssds ${WORKER_LOCAL_SSD_NUM} \
--image-version ${DATAPROC_IMAGE_VERSION} \
--service-account=${SERVICE_ACCOUNT} \
--project $PROJECT \
${OPT_COMP_STRING} \
${SCALING_POLICY_STRING} \
${PROPERTIES_STRING} \
${DPMS_STRING} \
${INIT_STRING}