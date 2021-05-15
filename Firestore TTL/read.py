from __future__ import absolute_import

from google.cloud import firestore
from datetime import date
from datetime import datetime
from datetime import timedelta
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

import argparse
import logging
import re
import io
import pytz
import apache_beam as beam

def run_ttl_job(element):
    collection_name_a, ttl_a, ttlcolumn_a = element
    collection_name = collection_name_a.get()
    ttl = ttl_a.get()
    ttl_column = ttlcolumn_a.get()
    if ttl_column == "":
      logging.info('Running Firestore TTL job for collection : %s with TTL: %s seconds',collection_name,ttl)
      now = datetime.now(pytz.timezone('US/Eastern'))
      #now = datetime.utcnow()
      
      db = firestore.Client()
      ttl_docs = db.collection(collection_name).stream()

      for doc in ttl_docs:   
        if (doc.create_time  < now - timedelta(seconds=int(ttl))):
          logging.info('This record is scheduled for deletion: %s time elapsed: %s',doc.id, now - doc.create_time)
          doc.reference.delete()
    else:
      logging.info('Running Firestore TTL job for collection : %s with TTL: %s seconds for TTL column: %s',collection_name,ttl, ttl_column)
      now = datetime.now(pytz.timezone('US/Eastern'))
      #now = datetime.utcnow()
      
      db = firestore.Client()
      ttl_docs = db.collection(collection_name).where(ttl_column, u"<", now - timedelta(seconds=int(ttl))).stream()

      for doc in ttl_docs:   
      #for doc in ttl_collection.stream():
          #if (doc.create_time + timedelta(seconds=int(ttl)) < now):
        logging.info('This record is scheduled for deletion: %s time elapsed: %s',doc.id, now - doc.create_time)
        doc.reference.delete()

def run(argv=None, save_main_session=True):

  class TTLOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
      parser.add_value_provider_argument(
          '--ttl',
          default='10',
          dest='ttl',
          required=True,
          help='TTL value in seconds')
      parser.add_value_provider_argument(
          '--collection',
          dest='collection',
          required=True,
          help='Name of collection to apply TTL on')
      parser.add_value_provider_argument(
          '--ttl_column',
          dest='ttlcolumn',
          default='',
          required=False,
          help='Column name for reading TTL expiration')

  # We use the save_main_session option because one or more DoFn's in this
  # workflow rely on global context (e.g., a module imported at module level).

  pipeline_options = PipelineOptions(flags=argv, save_main_session=True)
  ttl_options = pipeline_options.view_as(TTLOptions)

  # The pipeline will be run on exiting the with block.
  with beam.Pipeline(options=pipeline_options) as p:
    
    blank_record = p | 'Start' >> beam.Create([(ttl_options.collection, ttl_options.ttl, ttl_options.ttlcolumn)])
    ttl_records = blank_record | 'Call TTL' >> beam.FlatMap(run_ttl_job)
    
if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  run()
