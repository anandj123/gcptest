SRC_DIR="~/gcptest/techbash-aiml/v2"
touch $SRC_DIR/triggers/i01.s

gsutil cp gs://sureskills-ql/challenge-labs/tech-bash-2021/data-analytics/data_analytics.tar.gzip ~
tar -xvf ~/data_analytics.tar.gzip -C ~

touch $SRC_DIR/triggers/i01.f

