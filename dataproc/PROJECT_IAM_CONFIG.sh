# !/bin/bash
# You may need to configure this script only once depending on your service account changes or cluster location. 

# PROJECT LOCATION
export REGION='us-central1'
export ZONE='us-central1-a'

# MODIFY, IF REQUIRED
export PROJECT=$(gcloud info --format='value(config.project)')
export WAREHOUSE_BUCKET=${PROJECT}-warehouse
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT} --format="value(projectNumber)")
export GCS_BUCKET=${PROJECT}

# IAM
export SERVICE_ACCOUNT=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

echo SERVICE_ACCOUNT=$SERVICE_ACCOUNT

