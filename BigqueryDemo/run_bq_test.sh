#!/bin/bash
if [ -n "$1" ]; then
  echo "Google cloud storage bucket passed : "$1
else
  echo "Google cloud storage bucket not supplied."
  exit
fi
echo 'Copying query.txt file to GCS bucket'
gsutil cp query.txt $1

echo 'Running the program that processes the query.txt by running the queries aginst BQ'
echo '---------------------------------------------------------------------------------'
./bqrun.sh $1/query.txt
