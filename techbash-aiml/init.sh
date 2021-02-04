git clone https://github.com/GoogleCloudPlatform/dataflow-video-analytics.git

gcloud pubsub topics create gcs-notification-topic
gcloud pubsub subscriptions create gcs-notification-subscription --topic=gcs-notification-topic
gsutil mb gs://$(gcloud config get-value project)_videos
gsutil notification create -f json -t gcs-notification-topic gs://$(gcloud config get-value project)_videos
gcloud pubsub topics create object-detection-topic
gcloud pubsub subscriptions create object-detection-subscription --topic=object-detection-topic
gcloud pubsub topics create error-topic
gcloud pubsub subscriptions create error-subscription --topic=error-topic
printf '=%.0s' {1..100} 
printf "\nCreated topics.\n"
printf '=%.0s' {1..100} 
echo ''
bq mk video_analytics
bq mk video_analytics.object_tracking_analysis ~/dataflow-video-analytics/src/main/resources/table_schema.json
printf '=%.0s' {1..100} 
printf "\nCreated Bigquery tables.\n"
printf '=%.0s' {1..100} 
echo ''

gsutil mb gs://$(gcloud config get-value project)_videos_dftemplate
gsutil mb gs://$(gcloud config get-value project)_dataflow_template_config
export TT='{"image": "gcr.io/PROJECT_ID/dataflow-video-analytics","sdk_info":{"language": "JAVA"}}' 
echo  ${TT/PROJECT_ID/$PROJECT}> dynamic_template_video_analytics.json
gsutil cp  dynamic_template_video_analytics.json  gs://$(gcloud config get-value project)_dataflow_template_config/

echo  ${TT/PROJECT_ID/$PROJECT}
printf '\n\n\n'
gsutil cat gs://$(gcloud config get-value project)_dataflow_template_config/dynamic_template_video_analytics.json 

