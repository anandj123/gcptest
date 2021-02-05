        gcloud dataflow jobs run ecommerce-events-ps-to-bq-stream \
            --gcs-location gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery \
            --region us-central1 \
            --staging-location gs://$BUCKET_ID/temp \
            --parameters \ 
inputSubscription=projects/$PROJECT/subscriptions/ecommerce-events-pull,\
outputTableSpec=$PROJECT:retail_dataset.ecommerce_events,\
outputDeadletterTable=$PROJECT:retail_dataset.ecommerce_events_dead
