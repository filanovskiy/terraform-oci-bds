#!/bin/bash
sudo yum install -y dstat python36-oci-cli docker-engine
sudo service docker start
sudo docker pull iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen:latest
sudo docker run -v /tmp/tpcds:/tmp/tpcds iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen
for i in `find /tmp/tpcds/text/ -name "*"|grep -v _SUCCESS|grep -v crc|grep txt`; do  curl -X PUT --data-binary @$i https://objectstorage.us-ashburn-1.oraclecloud.com/p/v8R0rFt8nw3su83_5mIxX7FaMfnUyayVuOp_D-_3XS8/n/oraclebigdatadb/b/bucket-20200617-1916/o/$i ; done