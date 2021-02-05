touch ~/gcptest/techbash-ai/v2/triggers/f03.s
export PROJECT=$(gcloud config get-value project)

while :
do
    if [ -f "triggers/f01.f" ] 
    then
        
        gcloud builds submit \ 
            --tag gcr.io/$PROJECT/pubsub-proxy

        gcloud run deploy pubsub-proxy \ 
            --image gcr.io/$PROJECT/pubsub-proxy \ 
            --platform managed --region=us-central1 \ 
            --allow-unauthenticated

        break
    fi
    sleep 2
done

touch ~/gcptest/techbash-ai/v2/triggers/f03.f

