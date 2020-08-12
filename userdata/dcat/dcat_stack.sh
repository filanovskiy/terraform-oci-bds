#!/bin/bash
BUCKET_NAME=${1:-bikes_download}
# Create data asset and export data asset key
export DATA_ASSET_KEY=`oci data-catalog data-asset create --from-json file:///home/opc/dcat/create_data_asset.json --catalog-id $DCAT_OCID|jq '.data.key'  -c --raw-output`
# Create connection and capture
export CONNECTION_KEY=`oci data-catalog connection create --from-json file:///home/opc/dcat/create_connection.json --catalog-id $DCAT_OCID --data-asset-key $DATA_ASSET_KEY|jq '.data.key'  -c --raw-output`