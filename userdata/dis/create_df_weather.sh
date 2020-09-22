#!/bin/bash
oci os object rename --bucket-name weather_download --source-name "weather/central-park.csv" --new-name central-park.csv
export BUCKET_NAME=${1:-weather_download}
cp /home/opc/dis/create_data_flow.py /home/opc/dis/create_data_flow_updated.py
export DIS_DATA_ASSET=`oci data-integration data-asset list --workspace-id $DIS_OCID|jq '.data.items[0].key' -c --raw-output`
export DIS_CONNECTION=`oci data-integration data-asset list --workspace-id $DIS_OCID|jq '.data.items[0]."default-connection".key' -c --raw-output`
sed -i "s/DIS_WORKSPACE_VAR/$DIS_OCID/g" /home/opc/dis/create_data_flow_updated.py
sed -i "s/BUCKET_VAR/$BUCKET_NAME/g" /home/opc/dis/create_data_flow_updated.py
sed -i "s/CONNECTION_VAR/$DIS_CONNECTION/g" /home/opc/dis/create_data_flow_updated.py
sed -i "s/DATA_ASSET_VAR/$DIS_DATA_ASSET/g" /home/opc/dis/create_data_flow_updated.py
python3 /home/opc/dis/create_data_flow_updated.py