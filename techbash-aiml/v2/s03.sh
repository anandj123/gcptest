touch $SRC_DIR/triggers/s03.s

while :
do
    if [ -f "$SRC_DIR/triggers/i03.f" ] 
    then
        mkdir ~/dataflow-video-analytics/videos/
        pushd ~/dataflow-video-analytics/videos/
        gsutil cp gs://dataflow-video-analytics-test-clips/* .
        export FILE="cat.mp4"
        ffmpeg -i "$FILE" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${FILE%.*}~"%1d.mp4
        export FILE="gbikes_dinosaur.mp4"
        ffmpeg -i "$FILE" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${FILE%.*}~"%1d.mp4
        gsutil cp *~* gs://$(gcloud config get-value project)_videos/

        break
    fi
    sleep 2
done

touch $SRC_DIR//triggers/s03.f
