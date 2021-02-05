touch $SRC_DIR/triggers/f02.s

while :
do
    if [ -f "$SRC_DIR/triggers/i01.f" ] && [ -f "$SRC_DIR/triggers/i02.f" ]
    then

bq rm -f -r -d video_analytics
bq mk video_analytics
bq mk video_analytics.object_tracking_analysis $HOME/dataflow-video-analytics/src/main/resources/table_schema.json
bq rm -f -r -d retail_dataset
bq mk retail_dataset
bq mk retail_dataset.ecommerce_events $HOME/data_analytics/bq_schema_ecommerce_events.json

        #------------------------------------------------------------
        # Query 1
        #------------------------------------------------------------

bq query --nouse_legacy_sql 'SELECT min(file_name), entity FROM `video_analytics.object_tracking_analysis` where entity like "%bicycle%" or entity like "%person%" or entity like "%cat%" group by entity'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;'

        #------------------------------------------------------------
        # Query 2
        #------------------------------------------------------------

bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity order by file_name,entity;'
bq query --nouse_legacy_sql 'SELECT  file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by file_name,entity;' 
bq query --nouse_legacy_sql 'SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity;'
bq query --nouse_legacy_sql 'SELECT  min(file_name) file_name, entity, max(frame.confidence) max_confidence FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity;' 

        #------------------------------------------------------------
        # Query 3
        #------------------------------------------------------------

bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, frame.confidence as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset,frame.confidence order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT  entity, min(frame.processing_timestamp) as processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.timeOffset order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT  entity, frame.processing_timestamp, frame.timeOffset, max(frame.confidence) as confidence, max(frame.left) as `left`, max(frame.top) top,max(frame.right) as `right`, max(frame.bottom) as bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame group by entity, frame.processing_timestamp, frame.timeOffset order by frame.timeOffset asc;'
bq query --nouse_legacy_sql 'SELECT distinct entity, frame.processing_timestamp, frame.timeOffset, frame.confidence, frame.left, frame.top, frame.right, frame.bottom FROM `video_analytics.object_tracking_analysis`, UNNEST(frame_data) as frame order by frame.timeOffset asc, frame.confidence desc;'

        break
    fi
    sleep 2
done

touch $SRC_DIR/triggers/f02.f

