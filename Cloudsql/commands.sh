# Commands setup for using cloud sql proxy to cloud sql

## Setup and run the cloud sql proxy so that it can talk to cloud sql

```sh
curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
chmod +x cloud_sql_proxy
./cloud_sql_proxy -instances=anand-bq-test-2:us-east1:mysqlm=tcp:3306

```

## Install python mysql library to query the database

```sh

pip3 install pymysql

```



