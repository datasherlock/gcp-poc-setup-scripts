#!/bin/bash
#
set -x
# Parses out final state, start time, end time, and elapsed time for a single dataproc job.
idx=0
declare -a run_times
for i in `gcloud dataproc jobs list --region=us-central1 --cluster=$1 |  cut -d ' ' -f 1 | tail -n +2 |xargs -n 1`
do
JOBID=$i
TMPFILE="dataproc-job-desc-${JOBID}.txt"
gcloud dataproc jobs describe --region us-central1 ${JOBID} > ${TMPFILE}
FINAL_STATE=$(cat ${TMPFILE} | grep -B 1 'stateStartTime:' | head -n 1 | cut -d ':' -f 2 | xargs -n 1 echo)
START_DATE=$(cat $TMPFILE | grep -A 1 'state: PENDING' |  tail -n 1 | sed "s/.*'\(.*\)'.*/\1/" | cut -d "." -f1 | awk '{print $1"Z"}')
START_TS=$(date -j -u -f %Y-%m-%dT%H:%M:%SZ "${START_DATE}" +%s) 
END_DATE=$(cat ${TMPFILE} | grep 'stateStartTime:' | head -n 1 | sed "s/.*'\(.*\)'.*/\1/" | cut -d "." -f1 | awk '{print $1"Z"}')
END_TS=$(date -j -u -f %Y-%m-%dT%H:%M:%SZ "${END_DATE}" +%s) 
rm ${TMPFILE}
run_times[idx]=$(( ( ${END_TS} - ${START_TS} ) / 60 ))
idx=$(( idx+1 ))
echo $1,$i,$FINAL_STATE,$START_TS,$END_TS,$(( ( ${END_TS} - ${START_TS} ) / 60 )) >> run_details.csv
done

sum=0
for ele in ${run_times[@]}; do
  let sum=sum+ele
done
len=${#run_times[@]}
let avg=sum/len

echo -n "$avg"