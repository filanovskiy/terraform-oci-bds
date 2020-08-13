#!/bin/bash
BUCKET_NAME=${1:-bikes_download}
echo "Harvesting "$BUCKET_NAME "bucket"
export DATA_ASSET_KEY=`oci data-catalog data-asset list --catalog-id $DCAT_OCID|jq '.data.items[0].key'  -c --raw-output`
export CONNECTION_KEY=`oci data-catalog connection list --catalog-id $DCAT_OCID --data-asset-key $DATA_ASSET_KEY|jq '.data.items[0].key'  -c --raw-output`
cp  /home/opc/dcat/create_job_defenition.json /tmp/create_job_defenition.json
sed -i "s/DATA_ASSET_KEY_VAR/$DATA_ASSET_KEY/g" /tmp/create_job_defenition.json
sed -i "s/CONNECTION_KEY_VAR/$CONNECTION_KEY/g" /tmp/create_job_defenition.json
sed -i "s/BUCKET_VAR/$BUCKET_NAME/g" /tmp/create_job_defenition.json
sed -i "s/JOB_DEF_VAR/$BUCKET_NAME`date +%s`/g" /tmp/create_job_defenition.json
# Create Job Definition
#sed -i "s/JOB_DEF_VAR/$BUCKET_NAME/g" /home/opc/dcat/create_job_defenition.json
export JOB_DEF_KEY=`oci data-catalog job-definition create --catalog-id $DCAT_OCID --from-json file:///tmp/create_job_defenition.json|jq '.data.key'  -c --raw-output`
# Create Job
cp /home/opc/dcat/create_job.json /tmp/create_job.json
sed -i "s/JOB_DEF_KEY_VAR/$JOB_DEF_KEY/g" /tmp/create_job.json
sed -i "s/CONNECTION_KEY_VAR/$CONNECTION_KEY/g" /tmp/create_job.json
export JOB_KEY=`oci data-catalog job create --catalog-id $DCAT_OCID --from-json file:///tmp/create_job.json|jq '.data.key'  -c --raw-output`
oci data-catalog job-execution create --catalog-id $DCAT_OCID --job-key $JOB_KEY