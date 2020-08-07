#!/bin/bash
# Create data asset and export data asset key
export DATA_ASSET_KEY=`oci data-catalog data-asset create --from-json file:///home/opc/createda.json --catalog-id $DCAT_OCID|jq '.data.key'  -c --raw-output`
# Create connection and capture
oci data-catalog connection create --from-json file:///home/opc/createconn.json --catalog-id $DCAT_OCID --data-asset-key $DATA_ASSET_KEY --compartment_id $COMPARTMENT --region=us-ashburn-1