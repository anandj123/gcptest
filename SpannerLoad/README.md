# Spanner Load test
Use YCSB to load test spanner

```sh

#Directory where YCSB is present
/Users/anandjain/Documents/GitHub/YCSB/YCSB

# Update the config file to point YCSB to correct instance and database
/Users/anandjain/Documents/GitHub/YCSB/YCSB/cloudspanner/conf/cloudspanner.properties

     # Core YCSB properties.
     table = usertable
     zeropadding = 12

     # Cloud Spanner properties
     cloudspanner.instance = test-1
     cloudspanner.database = hello

# compile YCSB all library
# from the top level use
mvn package -DskipTests=true

#login to gcloud and run the workloada (insert a million record to the cloud spanner)
gcloud auth application-default login; ./bin/ycsb load cloudspanner -P cloudspanner/conf/cloudspanner.properties -P workloads/workloada -p recordcount=10000000 -p cloudspanner.batchinserts=1000 -threads 100 -s


gcloud auth application-default login; ./bin/ycsb load cloudspanner -P cloudspanner/conf/cloudspanner.properties -P workloads/workloada -p recordcount=10 -p cloudspanner.batchinserts=1000 -threads 10 -s

```

# Spanner Admin client demo in Golang
