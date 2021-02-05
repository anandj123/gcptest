touch $SRC_DIR/triggers/f03.s

while :
do
    if [ -f "$SRC_DIR/triggers/f01.f" ] 
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

touch $SRC_DIR/triggers/f03.f

