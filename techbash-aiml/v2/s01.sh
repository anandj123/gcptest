touch ~/gcptest/techbash-ai/v2/triggers/s01.s
export PROJECT=$(gcloud config get-value project)

while :
do
    if [ -f "triggers/i02.f" ] 
    then
        pushd ~/dataflow-video-analytics/
        gradle jib -DmainClass=com.google.solutions.df.video.analytics.VideoAnalyticsPipeline --image=gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest
        break
    fi
    sleep 2
done

touch ~/gcptest/techbash-ai/v2/triggers/s01.f

