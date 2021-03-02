#!/bin/bash
FIRST=$(date +%s%3)
TIMES=10
echo "Querying simple table: $TIMES times. Starting epoch: $FIRST"
for i in $(seq 1 $TIMES)
do
sql="SELECT s.FirstName, a.AlbumTitle FROM Singers AS s JOIN Albums AS a ON s.SingerId = a.SingerId WHERE a.SingerId=$i;"
gcloud spanner databases execute-sql test --instance=test-1 --sql="$sql" > /dev/null
done
SECOND=$(date +%s%3)
SUM=$((SECOND-FIRST))
AVG=$((SUM/TIMES))
echo "Total time:  $SUM milli seconds"
echo "Average time: $AVG milli seconds"


echo ''
FIRST=$(date +%s%3)
echo "Querying interleave table: $TIMES times. Starting epoch: $FIRST"
for i in $(seq 1 $TIMES)
do
sql="SELECT s.FirstName, a.AlbumTitle FROM Singers2 AS s JOIN Albums2 AS a ON s.SingerId = a.SingerId WHERE a.SingerId=$i;"
gcloud spanner databases execute-sql test --instance=test-1 --sql="$sql" >/dev/null
done
SECOND=$(date +%s%3)
SUM=$((SECOND-FIRST))
AVG=$((SUM/TIMES))
echo "Total time:  $SUM milli seconds"
echo "Average time: $AVG milli seconds"

