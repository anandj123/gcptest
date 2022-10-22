from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.contrib.operators.gcs_list_operator import GoogleCloudStorageListOperator
from airflow.models import Variable
from airflow.providers.google.cloud.transfers.gcs_to_gcs import GCSToGCSOperator
import json
#from airflow.utils.task_group import TaskGroup

import os
from datetime import datetime, timedelta

with DAG(dag_id='dynamic_dag_generation', schedule_interval=None, start_date=datetime(2022, 1, 1), catchup=False) as dag:

    d1 = DummyOperator(task_id='kick_off_dynamic_dag')

    def get_gcs_files(**kwargs):
        entries = os.listdir('/home/airflow/gcs/data/')
        vars = []
        for entry in entries:
            print("creating dynamic task for : " + entry)
            vars.append(entry)

        Variable.set(key='list_of_bash_scripts',
                     value=json.dumps(vars))
        
    t2 = PythonOperator(
        task_id='List_GCS_Files',
        python_callable=get_gcs_files,provide_context=True)

    entries = Variable.get('list_of_bash_scripts')
    entries = json.loads(entries)

    for entry in entries:      
        say_hello = BashOperator(
            task_id=f'run_bash_script_{entry}',
            bash_command=f'/home/airflow/gcs/data/{entry} ',    
        )
        d1 >> say_hello
