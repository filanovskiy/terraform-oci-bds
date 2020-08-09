#!/bin/bash
# Download trips data and upload to boject storage
BUCKET_NAME=${1:-bikes_download}

export TARGET_DIR=/tmp/bikes
export FILE_HOST="https://s3.amazonaws.com/tripdata/"
export FILE_LIST="
JC-201901-citibike-tripdata.csv.zip
JC-201902-citibike-tripdata.csv.zip
JC-201903-citibike-tripdata.csv.zip
JC-201904-citibike-tripdata.csv.zip
JC-201905-citibike-tripdata.csv.zip
JC-201906-citibike-tripdata.csv.zip
JC-201907-citibike-tripdata.csv.zip
JC-201908-citibike-tripdata.csv.zip
JC-201909-citibike-tripdata.csv.zip
JC-201910-citibike-tripdata.csv.zip
JC-201911-citibike-tripdata.csv.zip
JC-201912-citibike-tripdata.csv.zip"

cd $TARGET_DIR
mkdir -p $TARGET_DIR/csv_tmp
rm $TARGET_DIR/csv_tmp/*

for file in $FILE_LIST 
do
   s3obj="https://s3.amazonaws.com/tripdata/$file"
   echo "... downloading $s3obj to $TARGET_DIR"
   curl --remote-name --silent $s3obj 
   echo "... extracting $file to $TARGET_DIR/csv_tmp"
   unzip -o $TARGET_DIR/$file -d $TARGET_DIR/csv_tmp
done
oci os bucket create --name $BUCKET_NAME --compartment-id $COMPARTMENT
oci os object bulk-upload --bucket-name $BUCKET_NAME --src-dir /tmp/bikes/csv_tmp/