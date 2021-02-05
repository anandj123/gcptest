pushd ~/dataflow-video-analytics/
sudo apt-get install ffmpeg
mkdir videos
pushd ~/dataflow-video-analytics/videos/
gsutil cp gs://dataflow-video-analytics-test-clips/* .
export FILE="cat.mp4"
ffmpeg -i "$FILE" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${FILE%.*}~"%1d.mp4
export FILE="gbikes_dinosaur.mp4"
ffmpeg -i "$FILE" -codec:a aac  -ac 2  -ar 48k -c copy -movflags faststart -f segment -segment_format mpegts   -segment_time 5 "${FILE%.*}~"%1d.mp4
gsutil cp *~* gs://$(gcloud config get-value project)_videos/
printf '=%.0s' {1..100} 
printf "\nUploaded videos.\n"
printf '=%.0s' {1..100} 
echo ''
gsutil ls gs://$(gcloud config get-value project)_videos/
popd
popd