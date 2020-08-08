#!/bin/bash
# Create data asset and export data asset key
export DATA_ASSET_KEY=`oci data-catalog data-asset create --from-json file:///home/opc/dcat/create_data_asset.json --catalog-id $DCAT_OCID|jq '.data.key'  -c --raw-output`
# Create connection and capture
export CONNECTION_KEY=`oci data-catalog connection create --from-json file:///home/opc/dcat/create_connection.json --catalog-id $DCAT_OCID --data-asset-key $DATA_ASSET_KEY|jq '.data.key'  -c --raw-output`
# Patch Job definition JSON
sed -i "s/DATA_ASSET_KEY_VAR/$DATA_ASSET_KEY/g" /home/opc/dcat/create_job_defenition.json
sed -i "s/CONNECTION_KEY_VAR/$CONNECTION_KEY/g" /home/opc/dcat/create_job_defenition.json
# Create Job Definition
export JOB_DEF_KEY=`oci data-catalog job-definition create --catalog-id $DCAT_OCID --from-json file:///home/opc/dcat/create_job_defenition.json|jq '.data.key'  -c --raw-output`
# Create Job
sed -i "s/JOB_DEF_KEY_VAR/$JOB_DEF_KEY/g" /home/opc/dcat/create_job.json
sed -i "s/CONNECTION_KEY_VAR/$CONNECTION_KEY/g" /home/opc/dcat/create_job.json
export JOB_DEF_KEY=`oci data-catalog job create --catalog-id $DCAT_OCID --from-json file:///home/opc/dcat/create_job.json|jq '.data.key'  -c --raw-output`