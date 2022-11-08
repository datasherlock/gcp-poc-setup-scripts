# !/bin/bash

############################## Placement properties ###########################
export PROJECT=$(gcloud info --format='value(config.project)')
export REGION='us-central1'
export ZONE='us-central1-a'
################################################################################

# Create GCS Bucket
export GCS_BUCKET=${PROJECT}

# Job properties
export PROPERTIES='' # e.g. "mapreduce.job.maps=485,mapreduce.map.memory.mb=2048,mapreduce.map.java.opts=-Xmx1638m"
export TGT_TERAGEN_PATH=teragen_`date '+%Y%m%d%H%M%S'`
export TGT_TERASORT_PATH=terasort_`date '+%Y%m%d%H%M%S'`
export TGT_TERAVALIDATE_PATH=teravalidate_`date '+%Y%m%d%H%M%S'`