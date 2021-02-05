touch $SRC_DIR/triggers/f04.s
export BUCKET_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 30 | head -n 1)
gsutil mb gs://$BUCKET_ID
while :
do
    if [ -f "$SRC_DIR/triggers/f01.f" ] 
    then
        
        gcloud dataflow jobs run ecommerce-events-ps-to-bq-stream \
            --gcs-location gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery \
            --region us-central1 \
            --staging-location gs://$BUCKET_ID/temp \
            --parameters \ 
            inputSubscription=projects/$PROJECT/subscriptions/ecommerce-events-pull,\
            outputTableSpec=$PROJECT:retail_dataset.ecommerce_events,\
            outputDeadletterTable=$PROJECT:retail_dataset.ecommerce_events_dead

        break
    fi
    sleep 2
done

touch $SRC_DIR/triggers/f04.f

