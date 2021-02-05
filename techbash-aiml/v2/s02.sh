touch $SRC_DIR/triggers/s02.s

while :
do
    if [ -f "$SRC_DIR/triggers/f06.f" ] && [ -f "$SRC_DIR/triggers/s01.f" ]
    then
        export JOB_ID=$(gcloud dataflow jobs list --region=us-central1 --status=active| head -2 | tail -1|awk '{print $1}')
        gcloud dataflow jobs cancel $JOB_ID --region=us-central1
        while :
        do
            export JOB_ID=$(gcloud dataflow jobs list --region=us-central1 --status=active)
            if [ $JOB_ID == "Listed 0 items." ]
            then
                break
            fi
            sleep 2
        done

        export REGION="us-central1"
        export TEMPLATE_PATH=gs://$(gcloud config get-value project)_dataflow_template_config/dynamic_template_video_analytics.json
        export SUBSCRIPTION=gcs-notification-subscription

        gcloud dataflow flex-template run "streaming-beam-sql-`date +%Y%m%d-%H%M%S`" \
        --template-file-gcs-location "$TEMPLATE_PATH" \
        --parameters ^:^autoscalingAlgorithm="THROUGHPUT_BASED":\
numWorkers="5":maxNumWorkers="5":workerMachineType="n1-highmem-4":\
inputNotificationSubscription="projects/$PROJECT/subscriptions/gcs-notification-subscription":\
outputTopic="projects/$PROJECT/topics/object-detection-topic":\
errorTopic="projects/$PROJECT/topics/error-topic":\
features="OBJECT_TRACKING":entities="window,person":confidenceThreshold="0.9":windowInterval="1":\
tableReference="video_analytics.object_tracking_analysis":streaming="true" \
        --region "$REGION"

#TODO: wait for the dataflow job to get to started status

        break
    fi
    sleep 2
done

touch $SRC_DIR/triggers/s02.f

