touch $SRC_DIR/triggers/f05.s
while :
do
    if [ -f "$SRC_DIR/triggers/f01.f" ] && [ -f "$SRC_DIR/triggers/f03.f" ]
    then
pushd $HOME/data_analytics
# Todo: check if the service is accepting traffic
export SERVICE_URL=$(gcloud run services list --platform managed |tail -1 |awk '{print $4}')
curl -vX POST $SERVICE_URL/json -d @./ecommerce_view_event.json --header "Content-Type: application/json"
curl -vX POST $SERVICE_URL/json -d @./ecommerce_add_to_cart_event.json --header "Content-Type: application/json"
curl -vX POST $SERVICE_URL/json -d @./ecommerce_purchase_event.json --header "Content-Type: application/json"
#Todo: Check if the output of the post is successful
popd
        break
    fi
    sleep 2
done

touch $SRC_DIR/triggers/f05.f

