# mvn compile will compile and when you specify templateLocation this will 
# create a template at that location (in GCS). This will actually not run the
# dataflow job but just copy the jar files into the GCS location.
# tempLocation and stagingLocation are the same. Only one of them is used for staging
# files.

PROJECT_ID=anand-1
BUCKET_NAME=anand-1
PIPELINE_FOLDER=gs://${BUCKET_NAME}/dataflow/pipelines/pubsub-to-bigquery
USE_SUBSCRIPTION=false 
RUNNER=DataflowRunner

mvn compile exec:java \
-Dexec.mainClass=com.google.cloud.pso.pipeline.GmailDataflow \
-Dexec.cleanupDaemonThreads=false \
-Dexec.args=" \
--project=${PROJECT_ID} \
--tempLocation=${PIPELINE_FOLDER}/temp \
--stagingLocation=${PIPELINE_FOLDER}/staging \
--templateLocation=${PIPELINE_FOLDER}/template \
--runner=${RUNNER} \
--useSubscription=${USE_SUBSCRIPTION}"

# Once the template location is populated with the jar files then they can be launched
# using the gcloud dataflow command as below
JOB_NAME=pubsub-to-bigquery-$USER-`date +"%Y%m%d-%H%M%S%z"`
DATA_SET_ID=Anand_BQ_Test_1
TABLE_ID=demo_pubsub
DEAD_LETTER_TABLE_ID=${TABLE_ID}-deadletter-table
TOPIC_NAME="gmail-push"

gcloud dataflow jobs run ${JOB_NAME} \
--gcs-location=${PIPELINE_FOLDER}/template \
--zone=us-east1-d \
--parameters \
"inputTopic=projects/${PROJECT_ID}/topics/${TOPIC_NAME},\
outputTableSpec=${PROJECT_ID}:${DATA_SET_ID}.${TABLE_ID},\
outputDeadletterTable=${PROJECT_ID}:${DATA_SET_ID}.${DEAD_LETTER_TABLE_ID}"

# If there is a need to create a uber jar file for storing all the dependencies 
# then the following mvn command can be used for creating the uber jar file.
mvn clean package -DskipTests=true -Dcheckstyle.skip=true

# The uber jar file can be used for deploying the pipeline as follows
java -cp target/google-cloud-teleport-java-0.1-SNAPSHOT.jar com.google.cloud.teleport.templates.PubSubToBigQuery \
--runner=DataflowRunner \
--inputTopic=projects/${PROJECT_ID}/topics/demo4 \
--outputTableSpec=${PROJECT_ID}:${DATA_SET_ID}.${TABLE_ID} \
--zone=us-east1-d \
--outputDeadletterTable=${PROJECT_ID}:${DATA_SET_ID}.${DEAD_LETTER_TABLE_ID}




