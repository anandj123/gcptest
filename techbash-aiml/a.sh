# Part 1: In cloud shell go to the home directory and execute these scripts

#gcloud auth list

pushd  ~
git clone https://github.com/GoogleCloudPlatform/dataflow-video-analytics.git
pushd ~/dataflow-video-analytics/
gcloud pubsub topics create gcs-notification-topic
gcloud pubsub subscriptions create gcs-notification-subscription --topic=gcs-notification-topic
gsutil mb gs://$(gcloud config get-value project)_videos
gsutil notification create -f json -t gcs-notification-topic gs://$(gcloud config get-value project)_videos
gcloud pubsub topics create object-detection-topic
gcloud pubsub subscriptions create object-detection-subscription --topic=object-detection-topic
gcloud pubsub topics create error-topic
gcloud pubsub subscriptions create error-subscription --topic=error-topic
bq mk video_analytics
bq mk video_analytics.object_tracking_analysis src/main/resources/table_schema.json

gcloud pubsub topics create ecommerce-events
gcloud pubsub subscriptions create ecommerce-events-pull --topic=ecommerce-events
#echo "step 5: $((SECONDS-FIRST)) seconds"
bq mk retail_dataset
bq mk retail_dataset.ecommerce_events ../bq_schema_ecommerce_events.json
#echo "step 6: $((SECONDS-FIRST)) seconds"

nohup sh c.sh &
nohup sh d.sh &

gcloud config set project $(gcloud config get-value project)
gcloud services enable cloudbuild.googleapis.com

export PROJECT=$(gcloud config get-value project)
export FIRST=$SECONDS
export BUCKET_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 30 | head -n 1)

printf '=%.0s' {1..100} 
printf "\nStarting the first task\n\n"
printf '=%.0s' {1..100}
#gcloud config list project
pushd ~
export CASE_VAR=0
while [ $CASE_VAR -lt 10 ] 
do
printf '=%.0s' {1..100} 
printf "\n1. Build and Deploy cloud run service"
printf "\n2. Run Dataflow job."
printf "\n3. Check services are running."
printf "\n4. Post events to cloud run service."
printf "\n5. Check Bigquery."
printf "\n6. Delete Dataflow."
printf "\n10. Cleanup and exit.\n"
printf '=%.0s' {1..100}
printf "\nChoose your option: "

read CASE_VAR
case $CASE_VAR in
1)
gsutil cp gs://sureskills-ql/challenge-labs/tech-bash-2021/data-analytics/data_analytics.tar.gzip ~
tar -xvf ~/data_analytics.tar.gzip -C ~
pushd ~/data_analytics/pubsub_ecommerce
#echo "step 1: $((SECONDS-FIRST)) seconds"
gcloud builds submit --tag gcr.io/$PROJECT/pubsub-proxy
#echo "step 2: $((SECONDS-FIRST)) seconds"
gcloud run deploy pubsub-proxy --image gcr.io/$PROJECT/pubsub-proxy --platform managed --region=us-central1 --allow-unauthenticated
#echo "step 4: $((SECONDS-FIRST)) seconds"
;;
2)
gsutil mb gs://$BUCKET_ID
#echo "step 7: $((SECONDS-FIRST)) seconds"
gcloud dataflow jobs run ecommerce-events-ps-to-bq-stream \
    --gcs-location gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery \
    --region us-central1 \
    --staging-location gs://$BUCKET_ID/temp \
    --parameters \
inputSubscription=projects/$PROJECT/subscriptions/ecommerce-events-pull,\
outputTableSpec=$PROJECT:retail_dataset.ecommerce_events,\
outputDeadletterTable=$PROJECT:retail_dataset.ecommerce_events_dead
#echo "step 8: $((SECONDS-FIRST)) seconds"
;;
3)
#gcloud run services list --platform managed
#copy and paste it here.
export SERVICE_URL=$(gcloud run services list --platform managed |tail -1 |awk '{print $4}')
gcloud run services list --platform managed
gcloud dataflow jobs list --region=us-central1 --status=active
;;
4)
curl -vX POST $SERVICE_URL/json -d @../ecommerce_view_event.json --header "Content-Type: application/json"
echo "step 9: $((SECONDS-FIRST)) seconds"
curl -vX POST $SERVICE_URL/json -d @../ecommerce_add_to_cart_event.json --header "Content-Type: application/json"
echo "step 10: $((SECONDS-FIRST)) seconds"
curl -vX POST $SERVICE_URL/json -d @../ecommerce_purchase_event.json --header "Content-Type: application/json"
echo "step 11: $((SECONDS-FIRST)) seconds"
;;
5)
bq query --nouse_legacy_sql 'SELECT event_datetime, event, user_id FROM `qwiklabs-gcp-04-f069fbc9c7ce.retail_dataset.ecommerce_events`'
bq query --nouse_legacy_sql 'SELECT  min(event) as event ,count(event) as transactions, sum(ecommerce.purchase.value) as revenue FROM `qwiklabs-gcp-04-f069fbc9c7ce.retail_dataset.ecommerce_events` where event="purchase" group by ecommerce.purchase.transaction_id'
;;
6)
#set the job id for cancel
export JOB_ID=$(gcloud dataflow jobs list --region=us-central1 --status=active| head -2 | tail -1|awk '{print $1}')
gcloud dataflow jobs cancel $JOB_ID --region=us-central1
echo "step 14: $((SECONDS-FIRST)) seconds"
;;
10)
# Clean up script
gsutil rb gs://$BUCKET_ID
popd
popd
sh ~/gcptest/techbash-aiml/b.sh
esac
done