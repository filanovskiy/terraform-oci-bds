import time
import uuid
import oci
from oci.data_integration.data_integration_client import DataIntegrationClient
import dis_toolkit

#
# Simple 1:1 source/target dataflow, includes;
#   1. project rules on source to project all attributes
#   2. map by name rules on target
#   3. map by direct mapping from attribute LNAME to attribute LAST_NAME
#

srcDataAsset='DATA_ASSET_VAR'
srcConnection='CONNECTION_VAR'
tgtDataAsset='DATA_ASSET_VAR'
tgtConnection='CONNECTION_VAR'

df={
  "CSV_FILE":{ "dataAsset": srcDataAsset,
    "connection": srcConnection,
    "schema": 'BUCKET_VAR',
    "entity": 'central-park.csv',
    "entityType": "FILE_ENTITY",
    "dataFormat":{"type":"CSV","formatAttribute":{"encoding":"UTF-8","escapeCharacter":"\\","delimiter":",","quoteCharacter":"\"","hasHeader":"true","modelType":"CSV_FORMAT","timestampFormat":"yyyy-MM-dd HH:mm:ss.SSS"}},
    "to": ["PARQ_FILE.INPUT1"],
    "dataAssetType": "ORACLE_OBJECT_STORAGE_DATA_ASSET",
    "connectionType": "ORACLE_OBJECT_STORAGE_CONNECTION",
    "opType": "SOURCE",
    "projectionRules": [ {"ruleType": "INCLUDE", "matchType":"PATTERN","value": ".*"} ]
  },
"PARQ_FILE": {
    "from": ["CSV_FILE.OUTPUT1"],
    "dataAsset": tgtDataAsset,
    "connection": tgtConnection,
    "schema": 'BUCKET_VAR',
    "entity": 'central-park-parq/',
    "createNewEntity": 'true',
    "entityType": "FILE_ENTITY",
    #"dataFormat":{"type":"CSV","formatAttribute":{"encoding":"UTF-8","escapeCharacter":"\\","delimiter":",","quoteCharacter":"\"","hasHeader":"true","modelType":"CSV_FORMAT","timestampFormat":"yyyy-MM-dd HH:mm:ss.SSS"}},
    "dataFormat":{"type":"PARQUET"},
    "dataAssetType": "ORACLE_OBJECT_STORAGE_DATA_ASSET",
    "connectionType": "ORACLE_OBJECT_STORAGE_CONNECTION",
    "opType": "TARGET",
    "fieldMaps": [ {"mapType": "MAPBYNAME" } ]
  }
}

signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
#config = oci.config.from_file('~/.oci/config', 'DEFAULT')
di_client = DataIntegrationClient(config={}, signer=signer)
df_name = "EXAMPLE_" + str(round(time.time() * 1000))

workspace_id = 'DIS_WORKSPACE_VAR'
folder_id = None
data_flow = dis_toolkit.create_data_flow(di_client, workspace_id, df_name, df_name, folder_id, df)
print (data_flow.data)