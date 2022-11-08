# !/bin/bash

####################################################### CONFIGURATIONS START ###############################################################
echo "Getting project configurations..."
source project-config/PROJECT_IAM_CONFIG.sh
echo "Getting cluster configurations..."
[[ -z $1 ]] && echo "Please specify a config file. Exiting..." &&  exit 1 
[[ ! -f 'cluster-config/'$1 ]] && echo "Could not find config file. Please verify the name. Exiting..."  && exit 1

source cluster-config/$1

echo "Successfully imported.."
echo DATAPROC_OPTIONAL_COMPONENTS=$DATAPROC_OPTIONAL_COMPONENTS
echo DATAPROC_SCALING_POLICY=$DATAPROC_SCALING_POLICY
echo DATAPROC_METASTORE=$DATAPROC_METASTORE
echo DATAPROC_INITIALISATION_SCRIPTS=$DATAPROC_INITIALISATION_SCRIPTS
echo DATAPROC_PROPERTIES=$DATAPROC_PROPERTIES
echo MASTER_MACHINE_TYPE=$MASTER_MACHINE_TYPE
echo MASTER_BOOT_DISK_GB=$MASTER_BOOT_DISK_GB
echo MASTER_LOCAL_SSD_NUM=$MASTER_LOCAL_SSD_NUM
echo WORKER_MACHINE_TYPE=$WORKER_MACHINE_TYPE
echo WORKER_BOOT_DISK=$WORKER_BOOT_DISK
echo WORKER_LOCAL_SSD_NUM=$WORKER_LOCAL_SSD_NUM
echo WORKER_PRIMARY_CNT=$WORKER_PRIMARY_CNT
echo WORKER_SECONDARY_CNT=$WORKER_SECONDARY_CNT
echo WORKER_SECONDARY_LOCAL_SSD_NUM = $WORKER_SECONDARY_LOCAL_SSD_NUM
echo SERVICE_ACCOUNT=$SERVICE_ACCOUNT

####################################################### CONFIGURATIONS END ###############################################################

####################################################### VALIDATIONS START ###############################################################

[[ -z "$DATAPROC_PROPERTIES" ]] && PROPERTIES_STRING="" || PROPERTIES_STRING="--properties ${DATAPROC_PROPERTIES}"
[[ -z "$DATAPROC_METASTORE" ]] && DPMS_STRING="" || DPMS_STRING="--dataproc-metastore projects/${PROJECT}/locations/${REGION}/services/${DATAPROC_METASTORE}"
[[ -z "$DATAPROC_SCALING_POLICY" ]] && SCALING_POLICY_STRING="" || SCALING_POLICY_STRING="--autoscaling-policy ${DATAPROC_SCALING_POLICY}"
[[ -z "$DATAPROC_INITIALISATION_SCRIPTS" ]] && INIT_STRING="" || INIT_STRING="--initialization-actions ${DATAPROC_INITIALISATION_SCRIPTS}"
[[ -z "$DATAPROC_OPTIONAL_COMPONENTS" ]] && OPT_COMP_STRING="" || OPT_COMP_STRING="--optional-components ${DATAPROC_OPTIONAL_COMPONENTS}"
[[ -z $2 ]] && CLUSTER_NAME='poc-cluster-'`date '+%Y%m%d%H%M%S'` || CLUSTER_NAME=$2

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
--num-secondary-workers=${WORKER_SECONDARY_CNT} \
--num-secondary-worker-local-ssds=${WORKER_SECONDARY_LOCAL_SSD_NUM} \
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
--num-secondary-workers=${WORKER_SECONDARY_CNT} \
--num-secondary-worker-local-ssds=${WORKER_SECONDARY_LOCAL_SSD_NUM} \
--image-version ${DATAPROC_IMAGE_VERSION} \
--service-account=${SERVICE_ACCOUNT} \
--project $PROJECT \
${OPT_COMP_STRING} \
${SCALING_POLICY_STRING} \
${PROPERTIES_STRING} \
${DPMS_STRING} \
${INIT_STRING}