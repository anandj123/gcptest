# Part 2: In cloud shell go to the home directory and execute these scripts

export PROJECT=$(gcloud config get-value project)

export CASE_VAR=0
while [ $CASE_VAR -lt 10 ] 
do
printf '=%.0s' {1..100} 
printf "\n1. Check All."
printf "\n2. Run Dataflow job."
printf "\n3. Run Bigquery."
printf "\n4. Run Python."
printf "\n10. Cleanup and exit.\n"
printf '=%.0s' {1..100}
printf "\nChoose your option: "

read CASE_VAR
case $CASE_VAR in
1)
printf '\nDataflow job status.\n'
printf '=%.0s' {1..100} 
echo ''
gcloud dataflow jobs list --region=us-central1 --status=active
printf '\nVideo upload status.\n'
printf '=%.0s' {1..100} 
echo ''
gsutil ls gs://$(gcloud config get-value project)_videos/ 
printf '\nContainer images made.\n'
printf '=%.0s' {1..100} 
echo ''
gcloud container images list
;;
#gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest
2)
export REGION="us-central1"
export PROJECT=$(gcloud config get-value project)
export TEMPLATE_PATH=gs://$(gcloud config get-value project)_dataflow_template_config/dynamic_template_video_analytics.json
export SUBSCRIPTION=gcs-notification-subscription

gcloud dataflow flex-template run "streaming-beam-sql-`date +%Y%m%d-%H%M%S`" \
--template-file-gcs-location "$TEMPLATE_PATH" \
--parameters ^:^autoscalingAlgorithm="THROUGHPUT_BASED":\
numWorkers="5":maxNumWorkers="5":workerMachineType="n1-highmem-4":\
inputNotificationSubscription="projects/$PROJECT/subscriptions/gcs-notification-subscription":\
outputTopic="projects/$PROJECT/topics/object-detection-topic":\
errorTopic="projects/$PROJECT/topics/error-topic":\
features="OBJECT_TRACKING":entities="window,person":confidenceThreshold="0.9":windowInterval="1":\
tableReference="video_analytics.object_tracking_analysis":streaming="true" \
--region "$REGION"
;;
3)
bq query --nouse_legacy_sql 'SELECT min(file_name), entity FROM `video_analytics.object_tracking_analysis` where entity like "%bicycle%" or entity like "%person%" or entity like "%cat%" group by entity;'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;'
;;
4)
pip install google-cloud-pubsub
python pull-detections.py --project=$PROJECT --subscription=object-detection-subscription
;;
10)
popd
popd
popd
esac
done


