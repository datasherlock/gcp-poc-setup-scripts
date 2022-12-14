# !/bin/bash

# Datproc Image Version
export DATAPROC_IMAGE_VERSION='2.0.34-debian10'


# OPTIONAL. Leave empty if not required
export DATAPROC_OPTIONAL_COMPONENTS='JUPYTER,PRESTO'
export DATAPROC_SCALING_POLICY=''
export DATAPROC_METASTORE='' 
export DATAPROC_INITIALISATION_SCRIPTS='gs://datasherlock/dataproc-init-scripts/change_to_local_ssd.sh'  # comma delimited list of scripts e.g. gs://'${GCS_BUCKET}'/dataproc/initialisation_actions/change_to_local_ssd.sh
export DATAPROC_PROPERTIES=yarn:yarn.scheduler.capacity.resource-calculator=org.apache.hadoop.yarn.util.resource.DominantResourceCalculator,dataproc:efm.spark.shuffle=primary-worker,dataproc:dataproc.monitoring.stackdriver.enable=true,dataproc:dataproc.logging.stackdriver.job.driver.enable=true,dataproc:dataproc.logging.stackdriver.job.yarn.container.enable=true


export MASTER_MACHINE_TYPE='n2d-standard-4'
export MASTER_BOOT_DISK_GB=100
export MASTER_LOCAL_SSD_NUM=0

export WORKER_MACHINE_TYPE=n2d-standard-16
export WORKER_BOOT_DISK=150
export WORKER_LOCAL_SSD_NUM=0
export WORKER_PRIMARY_CNT=3
export WORKER_SECONDARY_CNT=9
export WORKER_SECONDARY_LOCAL_SSD_NUM=0