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
    coll_name_a, ttl_a = element
    coll_name = coll_name_a.get()
    ttl = ttl_a.get()
    logging.info('Running TTL job for collection : %s with TTL: %s seconds',coll_name,ttl)

    db = firestore.Client()
    ttl_coll = db.collection(coll_name)

    #now = datetime.utcnow()
    now = datetime.now(pytz.timezone('US/Eastern'))
    for doc in ttl_coll.stream():
        if (doc.create_time + timedelta(seconds=int(ttl)) < now):
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
          #required=True,
          help='Path of the file to read from')
      parser.add_value_provider_argument(
          '--collection',
          dest='collection',
          #required=True,
          help='Output file to write results to.')

  # We use the save_main_session option because one or more DoFn's in this
  # workflow rely on global context (e.g., a module imported at module level).

  pipeline_options = PipelineOptions(flags=argv, save_main_session=True)
  ttl_options = pipeline_options.view_as(TTLOptions)

  # The pipeline will be run on exiting the with block.
  with beam.Pipeline(options=pipeline_options) as p:
    
    blank_record = p | 'Start' >> beam.Create([(ttl_options.collection, ttl_options.ttl)])
    ttl_records = blank_record | 'Call TTL' >> beam.FlatMap(run_ttl_job)
    
if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  run()
