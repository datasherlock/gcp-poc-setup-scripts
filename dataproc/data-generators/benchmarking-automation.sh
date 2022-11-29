# !/bin/bash
cd ~/OSS/gcp-poc-setup-scripts/dataproc
#source cluster-config/benchmark_base_config.sh
total_nodes=12

function create_and_process() {
    mtype=$1 
    cores=$2 
    memory=$3 
    bootdisk=$4 
    pw=$5 
    sw=$6 
    efm=$7
    spcores=$8
    spinstances=$9
    spmemory=${10}
    if [[ $mtype == "Type" ]];
    then
    continue
    fi

    WORKER_MACHINE_TYPE=$mtype
    WORKER_BOOT_DISK=$bootdisk
    WORKER_PRIMARY_CNT=$(( $pw*$total_nodes/($pw+$sw) ))
    WORKER_SECONDARY_CNT=$(( $sw*$total_nodes/($pw+$sw) ))


    if [[ $efm == "y" ]];
    then
        DATAPROC_PROPERTIES='dataproc:efm.spark.shuffle=primary-worker,dataproc:dataproc.monitoring.stackdriver.enable=true,dataproc:dataproc.logging.stackdriver.job.driver.enable=true,dataproc:dataproc.logging.stackdriver.job.yarn.container.enable=true' # comma delimited list of scripts
    else
        DATAPROC_PROPERTIES='dataproc:dataproc.monitoring.stackdriver.enable=true,dataproc:dataproc.logging.stackdriver.job.driver.enable=true,dataproc:dataproc.logging.stackdriver.job.yarn.container.enable=true' # comma delimited list of scripts
    fi
    
    echo "Updating base configurations!"
    sed -i'' -e "s/.*WORKER_MACHINE_TYPE.*/export WORKER_MACHINE_TYPE=${WORKER_MACHINE_TYPE}/g" cluster-config/benchmark_base_config.sh
    sed -i'' -e "s/.*WORKER_BOOT_DISK.*/export WORKER_BOOT_DISK=${WORKER_BOOT_DISK}/g" cluster-config/benchmark_base_config.sh
    sed -i'' -e "s/.*WORKER_PRIMARY_CNT.*/export WORKER_PRIMARY_CNT=${WORKER_PRIMARY_CNT}/g" cluster-config/benchmark_base_config.sh
    sed -i'' -e "s/.*WORKER_SECONDARY_CNT.*/export WORKER_SECONDARY_CNT=${WORKER_SECONDARY_CNT}/g" cluster-config/benchmark_base_config.sh
    sed -i'' -e "s/.*DATAPROC_PROPERTIES.*/export DATAPROC_PROPERTIES=${DATAPROC_PROPERTIES}/g" cluster-config/benchmark_base_config.sh

    rm ~/OSS/gcp-poc-setup-scripts/dataproc/cluster-config/benchmark_base_config.sh-e
    
    CLUSTER_NM=poc-$mtype-$cores$bootdisk$pw$sw$efm
    CLUSTER_NM="${CLUSTER_NM%%[[:cntrl:]]}"
    echo "BM-Cluster Name = $CLUSTER_NM"
    . ~/OSS/gcp-poc-setup-scripts/dataproc/dataproc_create_cluster.sh "benchmark_base_config.sh" ${CLUSTER_NM}
    
    gcloud dataproc jobs submit pyspark \
    --cluster ${CLUSTER_NM} \
    --region us-central1 \
    --properties=spark.executor.cores=$spcores,spark.executor.instances=$spinstances,spark.executor.memory=$spmemory,spark.dynamicAllocation.enabled=false \
    gs://datasherlock/code/pyspark_process_agg_data.py -- gs://datasherlock/test_data/202211975917

    # for i in {1..5};
    # do
    # gcloud dataproc jobs submit pyspark \
    # --cluster ${CLUSTER_NM} \
    # --region us-central1 \
    # --properties=spark.executor.cores=$spcores,spark.executor.instances=$spinstances,spark.executor.memory=$spmemory,spark.dynamicAllocation.enabled=false \
    # gs://datasherlock/code/pyspark_process_agg_data.py -- gs://datasherlock/test_data/202211975917 &
    # sleep 5
    # done
    # wait
    
    #gcloud dataproc jobs list --region=us-central1 --cluster=${CLUSTER_NM} | cut -d ' ' -f 1 | xargs -n 1 ./fetch-results.sh
    avg=$(. ~/OSS/gcp-poc-setup-scripts/dataproc/data-generators/fetch-results.sh $CLUSTER_NM)
    echo "The run time is $avg"

    echo $mtype,$cores,$memory,$bootdisk,$pw,$sw,$efm,$avg,$spcores,$spinstances,$spmemory >>benchmark_results.csv

    gcloud dataproc clusters update ${CLUSTER_NM} --region=us-central1 --num-workers=2 --num-secondary-workers=0
}
i=0
while IFS=, read -r mtype cores memory bootdisk pw sw efm spcores spinstances spmemory; 
do 
    echo "Processing - " $mtype $cores $memory $bootdisk $pw $sw $efm $spcores $spinstances $spmemory
    create_and_process $mtype $cores $memory $bootdisk $pw $sw $efm $spcores $spinstances $spmemory &
    #echo $i
    sleep 5
    #  i=$(( $i + 1 ))
    #  if [[ $(( $i % 20 )) -eq 0 ]];
    #  then 
    #  echo "20 clusters submitted - Waiting"
    #  wait
    # fi
done < "/Users/jeromerajan/efm/efm_experiments.csv"
wait