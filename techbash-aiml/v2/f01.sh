touch ~/gcptest/techbash-ai/v2/triggers/f01.s
export PROJECT=$(gcloud config get-value project)

while :
do
    if [ -f "triggers/i01.f" ] && [ -f "triggers/i02.f" ]
    then
        gcloud pubsub topics create ecommerce-events
        gcloud pubsub subscriptions create ecommerce-events-pull \ 
            --topic=ecommerce-events
        gcloud pubsub topics create gcs-notification-topic
        gcloud pubsub subscriptions create \ 
            gcs-notification-subscription \ 
            --topic=gcs-notification-topic
        gcloud pubsub topics create object-detection-topic
        gcloud pubsub subscriptions create \ 
            object-detection-subscription \ 
            --topic=object-detection-topic
        gcloud pubsub topics create error-topic
        gcloud pubsub subscriptions create \ 
            error-subscription \ 
            --topic=error-topic

        gsutil mb gs://$(gcloud config get-value project)_videos

        gsutil mb gs://$(gcloud config get-value project)_videos_dftemplate
        gsutil mb gs://$(gcloud config get-value project)_dataflow_template_config
        
        export TT='{"image": "gcr.io/PROJECT_ID/dataflow-video-analytics","sdk_info":{"language": "JAVA"}}' 
        echo  ${TT/PROJECT_ID/$PROJECT}> dynamic_template_video_analytics.json
        gsutil cp  dynamic_template_video_analytics.json  gs://$(gcloud config get-value project)_dataflow_template_config/

        echo  ${TT/PROJECT_ID/$PROJECT}
        printf '\n\n\n'

        break
    fi
    sleep 2
done

touch ~/gcptest/techbash-ai/v2/triggers/f01.f

