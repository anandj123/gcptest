touch $SRC_DIR/triggers/s01.s

while :
do
    if [ -f "$SRC_DIR/triggers/i02.f" ] 
    then
        pushd $HOME/dataflow-video-analytics/
        gradle jib -DmainClass=com.google.solutions.df.video.analytics.VideoAnalyticsPipeline --image=gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest
        break
    fi
    sleep 2
done
popd
touch $SRC_DIR/triggers/s01.f

