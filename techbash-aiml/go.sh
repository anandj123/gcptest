# Part 1: In cloud shell go to the home directory and execute these scripts

cd  ~

gcloud auth list

gcloud config set project $(gcloud config get-value project)
export PROJECT=$(gcloud config get-value project)

gcloud config list project

gsutil cp gs://sureskills-ql/challenge-labs/tech-bash-2021/data-analytics/data_analytics.tar.gzip .
tar -xvf data_analytics.tar.gzip
if [ $? -eq 0 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 1: Could not extract gzip file. Exiting...\n\n"
    exit 500
fi

cd ~/data_analytics/pubsub_ecommerce

echo "Continue to next step: y/N"
read varname
if [[ $varname == "y" ]]; then
  echo "Continue"
else
  echo "Exit"
  exit 500
fi

gcloud builds submit --tag gcr.io/$PROJECT/pubsub-proxy
if [ $? -eq 0 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 2: Could not build pubsub-proxy or upload to gcr.io. Exiting...\n\n"
    exit 500
fi

gcloud run deploy pubsub-proxy --image gcr.io/$PROJECT/pubsub-proxy --platform managed --region=us-central1 --allow-unauthenticated
if [ $? -eq 0 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 3: Could not deploy pubsub-proxy from gcr.io. Exiting...\n\n"
    exit 500
fi

gcloud pubsub topics create ecommerce-events
if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 4: Could not make bucket. Exiting...\n\n"
    exit 500
fi
gcloud pubsub subscriptions create ecommerce-events-pull --topic=ecommerce-events
if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 4: Could not make bucket. Exiting...\n\n"
    exit 500
fi

echo -e 'y'|bq rm retail_dataset
if [ $? -eq 0 ] || [ $? -eq 2 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 4a: Could not remove retail_dataset. Exiting...\n\n"
    exit 500
fi

bq mk retail_dataset
bq mk retail_dataset.ecommerce_events ../bq_schema_ecommerce_events.json

gsutil mb gs://$PROJECT
if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 5: Could not make bucket. Exiting...\n\n"
    exit 500
fi

gcloud dataflow jobs run ecommerce-events-ps-to-bq-stream \
    --gcs-location gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery \
    --region us-central1 \
    --staging-location gs://$PROJECT/temp \
    --parameters \
inputSubscription=projects/$PROJECT/subscriptions/ecommerce-events-pull,\
outputTableSpec=$PROJECT:retail_dataset.ecommerce_events,\
outputDeadletterTable=$PROJECT:retail_dataset.ecommerce_events_dead
if [ $? -eq 0 ]; then
    echo OK
else
    printf '=%.0s' {1..100}
    printf "\nStep 4: Could not run dataflow job. Exiting...\n\n"
    exit 500
fi
gcloud run services list --platform managed
#copy and paste it here.
export SERVICE_URL=$(gcloud run services list --platform managed |tail -1 |awk '{print $4}')

curl -vX POST $SERVICE_URL/json -d @../ecommerce_view_event.json --header "Content-Type: application/json"

curl -vX POST $SERVICE_URL/json -d @../ecommerce_add_to_cart_event.json --header "Content-Type: application/json"

curl -vX POST $SERVICE_URL/json -d @../ecommerce_purchase_event.json --header "Content-Type: application/json"

bq query --nouse_legacy_sql 'SELECT event_datetime, event, user_id FROM `qwiklabs-gcp-04-f069fbc9c7ce.retail_dataset.ecommerce_events`'
bq query --nouse_legacy_sql 'SELECT  min(event) as event ,count(event) as transactions, sum(ecommerce.purchase.value) as revenue FROM `qwiklabs-gcp-04-f069fbc9c7ce.retail_dataset.ecommerce_events` where event="purchase" group by ecommerce.purchase.transaction_id'

gcloud dataflow jobs list --region=us-central1 --status=active
if [ $? -eq 0 ]; then
    echo OK
else
    echo FAIL
    exit 500
fi

#set the job id for cancel
export JOB_ID=$(gcloud dataflow jobs list --region=us-central1 --status=active| head -2 | tail -1|awk '{print $1}')

gcloud dataflow jobs cancel $JOB_ID --region=us-central1

gcloud dataflow jobs list --region=us-central1 --status=active


# Part 2: In cloud shell go to the home directory and execute these scripts

cd  ~
git clone https://github.com/GoogleCloudPlatform/dataflow-video-analytics.git

cd dataflow-video-analytics/

gcloud pubsub topics create gcs-notification-topic
gcloud pubsub subscriptions create gcs-notification-subscription --topic=gcs-notification-topic

gsutil mb gs://$(gcloud config get-value project)_videos
gsutil notification create -f json -t gcs-notification-topic gs://$(gcloud config get-value project)_videos

bq mk video_analytics

bq mk video_analytics.object_tracking_analysis src/main/resources/table_schema.json

gcloud pubsub topics create object-detection-topic
gcloud pubsub subscriptions create object-detection-subscription --topic=object-detection-topic

gcloud pubsub topics create error-topic
gcloud pubsub subscriptions create error-subscription --topic=error-topic

gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest

gradle jib -DmainClass=com.google.solutions.df.video.analytics.VideoAnalyticsPipeline --image=gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest

gsutil mb gs://$(gcloud config get-value project)_videos_dftemplate
gsutil mb gs://$(gcloud config get-value project)_dataflow_template_config

echo '{"image": "gcr.io/qwiklabs-gcp-04-f069fbc9c7ce/dataflow-video-analytics","sdk_info":{"language": "JAVA"}}' > dynamic_template_video_analytics.json

gsutil cp  dynamic_template_video_analytics.json  gs://$(gcloud config get-value project)_dataflow_template_config/

export REGION="us-central1"
export PROJECT=$(gcloud config get-value project)
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


sudo apt-get install ffmpeg

mkdir videos
cd videos/
gsutil cp gs://dataflow-video-analytics-test-clips/* .

export file="cat.mp4"
ffmpeg -i "$file" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${file%.*}~"%1d.mp4


export file="gbikes_dinosaur.mp4"
ffmpeg -i "$file" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${file%.*}~"%1d.mp4


gsutil cp *~* gs://$(gcloud config get-value project)_videos/

bq query --nouse_legacy_sql '\

SELECT distinct file_name, entity 
FROM `qwiklabs-gcp-04-f069fbc9c7ce.video_analytics.object_tracking_analysis` 
where entity like "bicycle%" or entity like "person" or entity like "cat";


SELECT  file_name, entity, max(frame.confidence) as max_confidence 
FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame 
group by file_name,entity
order by file_name,entity;


SELECT distinct entity, frame.processing_timestamp, frame.timeOffset, frame.confidence,frame.left,frame.top,frame.right,frame.bottom
FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame 
order by frame.timeOffset, frame.confidence desc;

'

pip install google-cloud-pubsub

python pull-detections.py --project=$PROJECT --subscription=object-detection-subscription


#------------------------------------------------------------
# Query 2
#------------------------------------------------------------

SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity
SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity
SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity 
SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity
SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity 

#------------------------------------------------------------
# Query 3
#------------------------------------------------------------

SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;
SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset order by frame.timeOffset asc; 
SELECT  entity, frame.processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.processing_timestamp, frame.timeOffset order by frame.timeOffset asc;
SELECT distinct entity, frame.processing_timestamp, frame.timeOffset, frame.confidence, frame.left, frame.top, frame.right, frame.bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame order by frame.timeOffset asc, frame.confidence desc;



git clone https://github.com/anandj123/gcptest.git; sh gcptest/techbash-aiml/a.sh


