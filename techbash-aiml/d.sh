pushd ~/dataflow-video-analytics/
sudo apt-get install ffmpeg
mkdir videos
pushd ./videos/
gsutil cp gs://dataflow-video-analytics-test-clips/* .
export file="cat.mp4"
ffmpeg -i "$file" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${file%.*}~"%1d.mp4
export file="gbikes_dinosaur.mp4"
ffmpeg -i "$file" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${file%.*}~"%1d.mp4
gsutil cp *~* gs://$(gcloud config get-value project)_videos/
