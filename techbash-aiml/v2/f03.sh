touch $SRC_DIR/triggers/f03.s

while :
do
    if [ -f "$SRC_DIR/triggers/i01.f" ] 
    then
gcloud services enable run.googleapis.com
pushd $HOME/data_analytics/pubsub_ecommerce
gcloud builds submit --tag gcr.io/$PROJECT/pubsub-proxy
gcloud run deploy pubsub-proxy --image gcr.io/$PROJECT/pubsub-proxy --platform managed --region=us-central1 --allow-unauthenticated 
popd

        break
    fi
    sleep 2
done

touch $SRC_DIR/triggers/f03.f

