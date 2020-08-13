#!/bin/bash
cp /home/opc/dis/dis_da_create.json /tmp/dis_da_create.json
sed -i "s/REGION_VAR/$REGION/g" /tmp/dis_da_create.json
sed -i "s/TENANCY_VAR/$TENANCY_OCID/g" /tmp/dis_da_create.json
sed -i "s/NAMESPACE_VAR/$OS_NAMESPACE/g" /tmp/dis_da_create.json
oci data-integration data-asset create --workspace-id $DIS_OCID --from-json file:///tmp/dis_da_create.json