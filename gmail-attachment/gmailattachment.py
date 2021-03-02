import argparse
import datetime
import json
import logging

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import apache_beam.transforms.window as window
import ast

from google.auth.transport.requests import Request
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
import base64

from google.oauth2 import service_account
from google.auth.transport import requests

from googleapiclient.discovery import build
from google.auth import default, iam

from google.auth import impersonated_credentials
'''
To run locally: 

export GOOGLE_APPLICATION_CREDENTIALS=/Users/anandjain/Documents/GitHub/gcptest/gmail-dataflow/src/main/java/com/google/cloud/pso/pipeline/anand-1-sa.json
gcloud auth activate-service-account --key-file=/Users/anandjain/Documents/GitHub/gcptest/gmail-dataflow/src/main/java/com/google/cloud/pso/pipeline/anand-1-sa.json


python gmailattachment.py

To run dataflow:

PROJECT=anand-1-291314
BUCKET=gs://anand-1/dataflow
REGION=us-east1
python -m gmailattachment --region $REGION --runner DataflowRunner --project $PROJECT --temp_location gs://$BUCKET/temp 


'''

TOKEN_URI = 'https://accounts.google.com/o/oauth2/token'
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']
EMAIL='anandj@eqxdemo.com'
MESSAGE_ID='177eaf1b98ab4a34'
ATTACHMENT_ID='ANGjdJ-MvhHmvbpGYPpgy3t4mfPEL-wLapjRrv4Bp40pqwEu2R24CvLqaXQLNGnTo70Ma4U2NO8SH_0uC98tSoqUnKyLqhvPvqfb28hEn91ICnvRK2Dpp4i2WCFum9gnKbT1wzfwrajeZ8mm6dj6KtlAgW0c0wjhPLTgSMwDXwt6YT8AAgHC6XHZ0K_NubQFax8_mIxoi4isZGLjY_Eb7Gv2uT5ZlThrR_tCjhiGWQ'
GSUITE_ADMIN_USER = 'test-anand-1@anand-1-291314.iam.gserviceaccount.com'

#SA_JSON=<INSERT_SA_JSON_HERE_AS_DICTIONARY_ENTRY_NO_QUOTES_ETC>
SA_JSON= "" 

class WriteAttachmentToGCS(beam.DoFn):
    def __init__(self, output_path):
        self.output_path = output_path

    def getattachment(self, email, messageId, attachementId):

        credentials = Credentials.from_service_account_info(SA_JSON)
        credentials = credentials.with_scopes(SCOPES)
        credentials = credentials.with_subject(email)
        try:
            request = requests.Request()
            
            credentials.refresh(request)

            # Create an IAM signer using the default credentials.
            # signer = iam.Signer(
            #     request,
            #     credentials,
            #     credentials.service_account_email
            # )
            # print('Service Account Email: ' + credentials.service_account_email)
            # # Create OAuth 2.0 Service Account credentials using the IAM-based
            # # signer and the bootstrap_credential's service account email.
            # updated_credentials = service_account.Credentials(
            #     signer,
            #     credentials.service_account_email,
            #     TOKEN_URI,
            #     scopes=SCOPES,
            #     subject=credentials.service_account_email
            # )
            
            # target_credentials = impersonated_credentials.Credentials(
            #         source_credentials=updated_credentials,
            #         target_principal=credentials.service_account_email,
            #         target_scopes=SCOPES,
            #         lifetime=500)

            # gmail = build('gmail', 'v1', credentials=updated_credentials,cache_discovery=False)
            # gmail = build('gmail', 'v1', credentials=target_credentials,cache_discovery=False)
            
            gmail = build('gmail', 'v1', credentials=credentials,cache_discovery=False)

            att = gmail.users().messages().attachments().get(userId=email, messageId=messageId, id=attachementId).execute()
            data = base64.b64decode(att['data'])
            return data
        except Exception as ex:
            print('Error:', ex.content.decode('ascii'))


    def process(self, element):
        e = element.decode("UTF-8")
        e = ast.literal_eval(e)
        messageId=e['id']
        att_file_name = ''
        att_text = ''
        for i in range(len(e['payload']['parts'])):
            if ('attachmentId' in e['payload']['parts'][i]['body']):

                attachmentId = e['payload']['parts'][i]['body']['attachmentId']
                att_file_name = e['payload']['parts'][i]['filename']

                for j in range(len(e['payload']['headers'])):
                    if (e['payload']['headers'][j]['name'] == 'To') :
                        em = e['payload']['headers'][j]['value']
                        start = em.find('<') + 1
                        end = em.find('>')
                        em = em[start:end]
                        att_text = self.getattachment(em, messageId, attachmentId)
                        break
                break

                
        filename = self.output_path + att_file_name #+ "-" + str(datetime.datetime.now())
        print('File Name of Attachement:' + filename)
        if (filename):
            with beam.io.gcp.gcsio.GcsIO().open(filename=filename, mode="w") as f:
                f.write(att_text)


def run(input_topic, output_path, window_size=1.0, pipeline_args=None):
    # `save_main_session` is set to true because some DoFn's rely on
    # globally imported modules.
    pipeline_options = PipelineOptions(
        pipeline_args, streaming=True, save_main_session=True
    )

    with beam.Pipeline(options=pipeline_options) as pipeline:
        (
            pipeline
            | "Read PubSub Messages"
            >> beam.io.ReadFromPubSub(topic=input_topic)
            # | "Window into" >> GroupWindowsIntoBatches(window_size)
            # | "Write to GCS" >> beam.ParDo(WriteBatchesToGCS(output_path))
            | "Write attachment to GCS" >> beam.ParDo(WriteAttachmentToGCS(output_path))
        )


if __name__ == "__main__":  # noqa
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_topic",
        help="The Cloud Pub/Sub topic to read from.\n"
        '"projects/anand-1-291314/topics/gmail-messages".',
        default="projects/anand-1-291314/topics/gmail-messages"
    )
    parser.add_argument(
        "--window_size",
        type=float,
        default=1.0,
        help="Output file's window size in number of minutes.",
    )
    parser.add_argument(
        "--output_path",
        help="GCS Path of the output file including filename prefix.",
        default="gs://anand-1/gmailattachment/attachments/test.data/"
    )
    known_args, pipeline_args = parser.parse_known_args()

    run(
        known_args.input_topic,
        known_args.output_path,
        known_args.window_size,
        pipeline_args,
    )