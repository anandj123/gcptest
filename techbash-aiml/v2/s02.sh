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
            echo "Job id: "$JOB_ID
            if [[ $JOB_ID = "" ]]
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

        while :
        do
            export JOB_ID=$(gcloud dataflow jobs list --region=us-central1 --status=active)
            echo "Job id: "$JOB_ID
            if [[ $JOB_ID = "" ]]
            then
                sleep 2
                continue
            fi
            break
        done
#TODO: wait for the dataflow job to get to started status

        break
    fi
    sleep 2
done

bq query --nouse_legacy_sql 'SELECT event_datetime, event, user_id FROM `retail_dataset.ecommerce_events`'
bq query --nouse_legacy_sql 'SELECT  min(event) as event ,count(event) as transactions, sum(ecommerce.purchase.value) as revenue FROM `retail_dataset.ecommerce_events` where event="purchase" group by ecommerce.purchase.transaction_id'

bq query --nouse_legacy_sql 'SELECT min(file_name), entity FROM `video_analytics.object_tracking_analysis` where entity like "%bicycle%" or entity like "%person%" or entity like "%cat%" group by entity'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;'

bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity;' 
bq query --nouse_legacy_sql 'SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity;'
bq query --nouse_legacy_sql 'SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity;' 

bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT  entity, frame.processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.processing_timestamp, frame.timeOffset order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT distinct entity, frame.processing_timestamp, frame.timeOffset, frame.confidence, frame.left, frame.top, frame.right, frame.bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame order by frame.timeOffset asc, frame.confidence desc;'

touch $SRC_DIR/triggers/s02.f

