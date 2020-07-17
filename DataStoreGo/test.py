from gcloud import datastore
import os

# the location of the JSON file on your local machine
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/Users/anandjain/Documents/GitHub/anand-bq-test-2-04cfb06c492d.json"


# project ID from the Developers Console
projectID = "anand-bq-test-2"

os.environ["GCLOUD_TESTS_PROJECT_ID"] = projectID
os.environ["GCLOUD_TESTS_DATASET_ID"] = projectID
client = datastore.Client(project=projectID)
query = client.query(kind='Job').fetch()
for r in query:
    print(r)