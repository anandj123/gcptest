#!/bin/bash
if [ -n "$1" ]; then
  echo "Biquery query file passed : "$1
else
  echo "Biquery query directory not supplied."
  exit
fi

rm -rf temp/

mkdir -p ./temp > /dev/null
pushd temp > /dev/null

# Load file from Google cloud storage to local for preocessing
gsutil -q cp $1 . > /dev/null

# split file by end query toke (;) into separate files
# so that they can be run one after another
csplit -k *.* '/\;/' {1} > /dev/null

FILES=xx*

for f in $FILES
do
  echo "-----------------------------------------------------------------------"
  echo "Processing $f file..."
  cat $f
  echo "-----------------------------------------------------------------------"
  # run query present in the file
  bq query "$(cat $f)"
done

popd
rm -rf temp/