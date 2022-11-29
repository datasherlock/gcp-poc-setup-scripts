# !/bin/bash

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

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

[[ -z "$DATAPROC_INITIALISATION_SCRIPTS" ]] && INIT_STRING="" || INIT_STRING="--initialization-actions ${DATAPROC_INITIALISATION_SCRIPTS}"
[[ -z "$DATAPROC_OPTIONAL_COMPONENTS" ]] && OPT_COMP_STRING="" || OPT_COMP_STRING="--optional-components ${DATAPROC_OPTIONAL_COMPONENTS}"
[[ -z $2 ]] && CLUSTER_NAME='poc-cluster-'`date '+%Y%m%d%H%M%S'` || CLUSTER_NAME=$2

####################################################### VALIDATIONS END ###############################################################

############################################### Fix scaling policy ###########################################
echo "Reading scaling policy"
echo "Cluster Name =  ${CLUSTER_NAME} "
if [[ -z "$DATAPROC_SCALING_POLICY" ]]; 
then
export SCALING_POLICY_STRING=""
else 
gcloud dataproc autoscaling-policies export $DATAPROC_SCALING_POLICY \
--region=$REGION \
--destination=${CLUSTER_NAME}-scaling-policy.yaml

echo "Parsing scaling policy"
parse_yaml ${CLUSTER_NAME}-scaling-policy.yaml

echo "Setting new scaling policy"
DATAPROC_SCALING_POLICY=${CLUSTER_NAME}-scaling-policy

workerConfig_minInstances=${WORKER_PRIMARY_CNT}
secondaryWorkerConfig_minInstances=${WORKER_SECONDARY_CNT}

echo "Updating scaling policy with values from cluster config"
yq -i '.workerConfig.minInstances='${workerConfig_minInstances} ${CLUSTER_NAME}-scaling-policy.yaml
yq -i '.workerConfig.maxInstances='${workerConfig_minInstances} ${CLUSTER_NAME}-scaling-policy.yaml
yq -i '.secondaryWorkerConfig.minInstances='${secondaryWorkerConfig_minInstances} ${CLUSTER_NAME}-scaling-policy.yaml

echo "Creating new scaling policy with updated values"
yes | gcloud dataproc autoscaling-policies import ${DATAPROC_SCALING_POLICY} \
--region=$REGION \
--source=${DATAPROC_SCALING_POLICY}.yaml

echo "Creating scaling string"
SCALING_POLICY_STRING="--autoscaling-policy ${DATAPROC_SCALING_POLICY}"
echo "Cleaning up....."
rm ${DATAPROC_SCALING_POLICY}.yaml
fi
########################################################################################################################

echo "Creating cluster using - 
gcloud dataproc clusters create ${CLUSTER_NAME} \
--enable-component-gateway \
--region $REGION \
--subnet default \
--zone $ZONE \
--no-address \
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

status=1
while [ $status -ne 0 ];
do
echo "Attempting to create ${CLUSTER_NAME}"
gcloud dataproc clusters create ${CLUSTER_NAME} \
--enable-component-gateway \
--region $REGION \
--no-address \
--subnet default \
--worker-boot-disk-type=pd-ssd \
--secondary-worker-boot-disk-type=pd-ssd \
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
--labels type=${WORKER_MACHINE_TYPE},purpose=efm-benchmarking,ratio=${WORKER_PRIMARY_CNT}-${WORKER_SECONDARY_CNT} \
${OPT_COMP_STRING} \
${SCALING_POLICY_STRING} \
${PROPERTIES_STRING} \
${DPMS_STRING} \
${INIT_STRING}
status=$?
retries=0
if [ $status -ne 0 -a $retries -lt 60 ];
then
echo "Error Creating Cluster. Reattempting $retries time in 1 minute....."
gcloud dataproc clusters delete ${CLUSTER_NAME} --region=us-central1
sleep 60
retries=$(( $retries + 1 ))
fi
done