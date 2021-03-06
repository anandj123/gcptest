# Part 1: In cloud shell go to the home directory and execute these scripts

#gcloud auth list
pushd  ~
export PROJECT=$(gcloud config get-value project)
export FIRST=$SECONDS
export BUCKET_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 30 | head -n 1)

gcloud pubsub topics create ecommerce-events
gcloud pubsub subscriptions create ecommerce-events-pull --topic=ecommerce-events


gcloud config set project $(gcloud config get-value project)
gcloud services enable cloudbuild.googleapis.com

printf '=%.0s' {1..100} 
printf "\nStarting the first task\n\n"
printf '=%.0s' {1..100}
#gcloud config list project
pushd ~
export CASE_VAR=0
while [ $CASE_VAR -lt 10 ] 
do
printf '=%.0s' {1..100} 
printf "\n1. Build and Deploy cloud run and dataflow service"
printf "\n2. Check services are running."
printf "\n3. Post events to cloud run service."
printf "\n4. Delete Dataflow."
printf "\n10. Cleanup and exit.\n"
printf '=%.0s' {1..100}
printf "\nChoose your option: "

read CASE_VAR
case $CASE_VAR in
1)
gsutil cp gs://sureskills-ql/challenge-labs/tech-bash-2021/data-analytics/data_analytics.tar.gzip ~
tar -xvf ~/data_analytics.tar.gzip -C ~
pushd ~/data_analytics/pubsub_ecommerce
bq mk retail_dataset
bq mk retail_dataset.ecommerce_events ~/data_analytics/bq_schema_ecommerce_events.json
gcloud builds submit --tag gcr.io/$PROJECT/pubsub-proxy

gcloud run deploy pubsub-proxy --image gcr.io/$PROJECT/pubsub-proxy --platform managed --region=us-central1 --allow-unauthenticated

gsutil mb gs://$BUCKET_ID

gcloud dataflow jobs run ecommerce-events-ps-to-bq-stream \
    --gcs-location gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery \
    --region us-central1 \
    --staging-location gs://$BUCKET_ID/temp \
    --parameters \
inputSubscription=projects/$PROJECT/subscriptions/ecommerce-events-pull,\
outputTableSpec=$PROJECT:retail_dataset.ecommerce_events,\
outputDeadletterTable=$PROJECT:retail_dataset.ecommerce_events_dead
;;
2)
#gcloud run services list --platform managed
#copy and paste it here.
export SERVICE_URL=$(gcloud run services list --platform managed |tail -1 |awk '{print $4}')
gcloud run services list --platform managed
gcloud dataflow jobs list --region=us-central1 --status=active
;;
3)
curl -vX POST $SERVICE_URL/json -d @../ecommerce_view_event.json --header "Content-Type: application/json"
echo "step 9: $((SECONDS-FIRST)) seconds"
curl -vX POST $SERVICE_URL/json -d @../ecommerce_add_to_cart_event.json --header "Content-Type: application/json"
echo "step 10: $((SECONDS-FIRST)) seconds"
curl -vX POST $SERVICE_URL/json -d @../ecommerce_purchase_event.json --header "Content-Type: application/json"
echo "step 11: $((SECONDS-FIRST)) seconds"
;;
4)
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