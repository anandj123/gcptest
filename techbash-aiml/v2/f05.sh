touch ~/gcptest/techbash-ai/v2/triggers/f05.s
export PROJECT=$(gcloud config get-value project)
export BUCKET_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 30 | head -n 1)
gsutil mb gs://$BUCKET_ID
while :
do
    if [ -f "triggers/f01.f" ] 
    then

# Todo: check if the service is accepting traffic
        export SERVICE_URL=$(gcloud run services list --platform managed |tail -1 |awk '{print $4}')
        curl -vX POST $SERVICE_URL/json -d @../ecommerce_view_event.json --header "Content-Type: application/json"
        curl -vX POST $SERVICE_URL/json -d @../ecommerce_add_to_cart_event.json --header "Content-Type: application/json"
        curl -vX POST $SERVICE_URL/json -d @../ecommerce_purchase_event.json --header "Content-Type: application/json"
#Todo: Check if the output of the post is successful

        break
    fi
    sleep 2
done

touch ~/gcptest/techbash-ai/v2/triggers/f05.f

