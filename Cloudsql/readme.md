# Commands setup for using cloud sql proxy to cloud sql

## Setup and run the cloud sql proxy so that it can talk to cloud sql

```sh
curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
chmod +x cloud_sql_proxy
./cloud_sql_proxy -instances=anand-bq-test-2:us-east1:mysqlm=tcp:3306

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
lsof -i :3306

```
## Setting up Cloud SQL regional replication for region failover

``` sh

gsutil cat gs://anand-bq-test-2/mysql/mysqlm-test/

mysqldump -h 127.0.0.1 -P 3306 -u root -p --databases test |gzip |gsutil cp - gs://anand-bq-test-2/mysql/mysqlm-test

mysql -h 127.0.0.1 -u root -p

# you should see a MySQL prompt 
CREATE USER 'mysqls'@'%' IDENTIFIED BY '[REPLICATION_PASSWORD]';
GRANT REPLICATION SLAVE ON *.* TO 'mysqls'@'%';


#enable binary log for the master
gcloud sql instances patch mysqlm --enable-bin-log --backup-start-time 12:00


gcloud beta sql instances create mysqls \
    --region=us-central1 \
    --enable-bin-log \
    --master-instance-name=mysqlm \
    --master-username=mysqls2 --prompt-for-master-password \
    --master-dump-file-path=gs://anand-bq-test-2/mysql/mysqlm-test \
    --tier=db-n1-standard-2 --storage-size=10


gcloud beta sql instances create mysqls3 \
    --region=us-central1 \
    --enable-bin-log \
    --backup-start-time 12:00 \
    --tier=db-n1-standard-2 \
    --storage-size=10 \
    --master-dump-file-path=gs://anand-bq-test-2/mysql/mysqlm-test \
    --master-username=mysqls2 --prompt-for-master-password \
    --master-instance-name=mysqlm


gcloud sql instances describe mysqls \
  --format="default(ipAddresses)"

gcloud sql instances patch mysqlm --enable-bin-log --backup-start-time 12:00


gcloud sql instances patch mysqlm
```

