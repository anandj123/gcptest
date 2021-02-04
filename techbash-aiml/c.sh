pushd ~/dataflow-video-analytics/

gradle jib -DmainClass=com.google.solutions.df.video.analytics.VideoAnalyticsPipeline --image=gcr.io/$(gcloud config get-value project)/dataflow-video-analytics:latest
gsutil mb gs://$(gcloud config get-value project)_videos_dftemplate
gsutil mb gs://$(gcloud config get-value project)_dataflow_template_config
echo '{"image": "gcr.io/qwiklabs-gcp-04-f069fbc9c7ce/dataflow-video-analytics","sdk_info":{"language": "JAVA"}}' > dynamic_template_video_analytics.json
gsutil cp  dynamic_template_video_analytics.json  gs://$(gcloud config get-value project)_dataflow_template_config/
