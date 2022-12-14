# !/bin/bash

# Datproc Image Version
export DATAPROC_IMAGE_VERSION='2.0-debian10'


# OPTIONAL. Leave empty if not required
export DATAPROC_OPTIONAL_COMPONENTS='JUPYTER,PRESTO'
export DATAPROC_SCALING_POLICY='demo-scaling-policy'
export DATAPROC_METASTORE='demo-metastore' 
export DATAPROC_INITIALISATION_SCRIPTS='gs://goog-dataproc-initialization-actions-us-central1/dr-elephant/dr-elephant.sh'  # comma delimited list of scripts e.g. gs://'${GCS_BUCKET}'/dataproc/initialisation_actions/change_to_local_ssd.sh
export DATAPROC_PROPERTIES='dataproc:efm.spark.shuffle=primary-worker' # comma delimited list of scripts

export MASTER_MACHINE_TYPE='n2d-standard-2'
export MASTER_BOOT_DISK_GB=100
export MASTER_LOCAL_SSD_NUM=2

export WORKER_MACHINE_TYPE='n2d-standard-2'
export WORKER_BOOT_DISK=100
export WORKER_LOCAL_SSD_NUM=2
export WORKER_PRIMARY_CNT=2
export WORKER_SECONDARY_CNT=2
