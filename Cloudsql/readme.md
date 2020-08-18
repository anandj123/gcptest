# Commands setup for using cloud sql proxy to cloud sql

## Setup and run the cloud sql proxy so that it can talk to cloud sql

```sh

curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
chmod +x cloud_sql_proxy

./cloud_sql_proxy -instances=anand-bq-test-2:us-east1:mysqlm=tcp:3307 &

mysql -u root -p --host 127.0.0.1 -P 3307

# Search mysql client in apt-get cache
apt-cache search libmysqlclient


```
## Download and install mysql workbench to use Cloud SQL

configure mysql workbench by adding it to path

```sh

vim ~/.bash_profile
export PATH=/usr/local/mysql-8.0.15-macos10.14-x86_64/bin:$PATH
source ~/.bash_profile

```
## Install python mysql library to query the database

```sh

pip3 install pymysql

```
## Finding out if the cloud sql proxy is running

```sh

lsof -i :3307

```
## Setting up Cloud SQL regional replication for region failover

``` sh

# Create a master database for the test
gcloud sql instances create mysqlm3 \
    --region=us-east1 \
    --enable-bin-log \
    --tier=db-n1-standard-2 --storage-size=10 \
    --prompt-for-password

# Set root password
gcloud sql users set-password root --host=% --instance=mysqlm3 --prompt-for-password

#enable binary log for the master
gcloud sql instances patch mysqlm3 --enable-bin-log --backup-start-time 12:00

# Prepare (load) data for mysql
sysbench oltp_read_write --table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=root --mysql-host=127.0.0.1 --mysql-port=3307 prepare

# Create a dump file of the master database for creating the read replica
mysqldump \
    -h 127.0.0.1 -P 3307 -u root -p \
    --databases test  \
    --hex-blob  --skip-triggers  --master-data=0  \
    --order-by-primary --no-autocommit \
    --default-character-set=utf8mb4 \
    --single-transaction \
    --set-gtid-purged=off \
    | gzip | gsutil cp - gs://anand-bq-test-2/mysqlm3/test.sql.gz

# you should see a MySQL prompt 
CREATE USER 'mysqls'@'%' IDENTIFIED BY '[REPLICATION_PASSWORD]';
GRANT REPLICATION SLAVE ON *.* TO 'mysqls'@'%';

# Create the read replica from the sql dump pointing to master
gcloud beta sql instances create mysqlm3-r1 \
    --master-instance-name=mysqlm3 \
    --region=us-west1 \
    --master-dump-file-path=gs://anand-bq-test-2/mysqlm3/test.sql.gz \
    --master-username=mysqls --prompt-for-master-password \
    --tier=db-n1-standard-2 --storage-size=20



gcloud sql instances describe mysqlm3 --format="default(ipAddresses)"


# Promote the replica as master
gcloud sql instances promote-replica mysqm3-r1


# Make the master the read-replica of the slave
gcloud sql instances create mysqlm3 --master-instance-name=mysqm3-r1

```
### Running sysbench for load testing CloudSQL

``` sh
-- Prepare (load) data for mysql

sysbench oltp_read_write --table-size=10000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=root --mysql-host=127.0.0.1 --mysql-port=3307 prepare

-- Run test for mysql

sysbench /usr/local/share/sysbench/oltp_read_write.lua --threads=100 --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=root --mysql-password='root' --mysql-db=test --db-driver=mysql --table-size=10000000 --delete_inserts=100 --index_updates=100 --non_index_updates=100 --report-interval=10 --time=1000 run

sysbench /usr/local/share/sysbench/oltp_read_write.lua --threads=50 --mysql-host=35.227.123.213 --mysql-port=3306 --mysql-user=root --mysql-password='root' --mysql-db=test --db-driver=mysql --table-size=10000000 --delete_inserts=100 --index_updates=100 --non_index_updates=100 --report-interval=10 --time=1000 run



```

https://cloud.google.com/vision/docs/quickstart-cli

To use vision API using REST API command
curl -X POST \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://vision.googleapis.com/v1/images:annotate -d @request.json


To get monitored resources using REST API
### Find all the monitored resource descriptors
curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/monitoredResourceDescriptors/

### Find all the metrics descriptions
curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/metricDescriptors

### Find all the monitored resources for cloudsql_databases
curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/monitoredResourceDescriptors/cloudsql_database

curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/monitoredResourceDescriptors/cloudsql_database/project_id=\"anand-bq-test-2\"


curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/metricDescriptors/cloudsql.googleapis.com/database/available_for_failover

curl -X GET \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/metricDescriptors/cloudsql.googleapis.com/database/mysql/replication/seconds_behind_master/


### To get metrics for any resource use the following syntx reference

https://cloud.google.com/monitoring/mql/reference#fetching-group

"query": "fetch cloudsql_database :: cloudsql.googleapis.com/database/mysql/queries | window 5m"

curl -X POST \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
https://monitoring.googleapis.com/v3/projects/anand-bq-test-2/timeSeries:query -d @request2.json

### YCSB spanner loads

```sh

./bin/ycsb run cloudspanner -P cloudspanner/conf/cloudspanner.properties -P workloads/workloadb -p recordcount=100 -p operationcount=10 -threads 1 -s

```