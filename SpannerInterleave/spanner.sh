#!/bin/bash
sql=''

for i in {1..100}
do
firstname=$(cat /dev/random | xxd -l 32 -c 32 -p)
lastname=$(cat /dev/random | xxd -l 32 -c 32 -p)
sql="INSERT Singers (SingerId, FirstName, LastName) VALUES ($i, '$firstname', '$lastname');"
gcloud spanner databases execute-sql test --instance=test-1 \
--sql="$sql" 
done

for i in {1..100}
do
firstname=$(cat /dev/random | xxd -l 32 -c 32 -p)
lastname=$(cat /dev/random | xxd -l 32 -c 32 -p)
sql="INSERT Singers2 (SingerId, FirstName, LastName) VALUES ($i, '$firstname', '$lastname');"
gcloud spanner databases execute-sql test --instance=test-1 \
--sql="$sql" 
done

for i in {1..100}
do
for j in {1..10}
do
firstname=$(cat /dev/random | xxd -l 32 -c 32 -p)
sql="INSERT Albums (SingerId, AlbumId, AlbumTitle) VALUES ($i, $j, '$firstname');"
gcloud spanner databases execute-sql test --instance=test-1 \
--sql="$sql" 
done
done

for i in {1..100}
do
for j in {1..10}
do
firstname=$(cat /dev/random | xxd -l 32 -c 32 -p)
sql="INSERT Albums2 (SingerId, AlbumId, AlbumTitle) VALUES ($i, $j, '$firstname');"
gcloud spanner databases execute-sql test --instance=test-1 \
--sql="$sql" 
done
done
