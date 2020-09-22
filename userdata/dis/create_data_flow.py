import calendar
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
    "entity": 'central-park-weather-parq/',
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

dfkey = data_flow.data.key

#
# Create Integration Task
#
registryMetadata = oci.data_integration.models.RegistryMetadata(aggregator_key=folder_id)
createTask = oci.data_integration.models.CreateTaskFromIntegrationTask(name="TASK_"+df_name, identifier="PYTHON_TASK_"+df_name, registry_metadata=registryMetadata, data_flow=oci.data_integration.models.DataFlow(key=dfkey))
task = di_client.create_task(workspace_id,create_task_details=createTask)
task_key=task.data.key
print ('Task created: ' + task.data.key)


#
# Create Application
#
app_name="PYTHON_APP" + str(round(time.time() * 1000))
createApplication = oci.data_integration.models.CreateApplicationDetails(name=app_name, identifier=app_name, model_type="INTEGRATION_APPLICATION")
app = di_client.create_application(workspace_id,create_application_details=createApplication)
app_key = app.data.key
objectsToPublish=[]
objectsToPublish.append(task_key)

#
# Create Patch in Application
#
patch_name="PATCH" + str(round(time.time() * 1000))
createPatch = oci.data_integration.models.CreatePatchDetails(name=patch_name, identifier=patch_name, patch_type=oci.data_integration.models.CreatePatchDetails.PATCH_TYPE_PUBLISH,object_keys=objectsToPublish)
patch = di_client.create_patch(workspace_id,app_key,create_patch_details=createPatch)


for x in range(30):
  time.sleep(1)
  patch = di_client.get_patch(workspace_id,app_key, patch_key=patch.data.key)
  if (patch.data.patch_status == "SUCCESSFUL"):
    break

taskkey = patch.data.patch_object_metadata[0].key
genkey = str(calendar.timegm(time.gmtime()))
md = oci.data_integration.models.RegistryMetadata(aggregator_key=taskkey)
task = oci.data_integration.models.CreateTaskRunDetails(key=genkey, registry_metadata=md)
tskrun = di_client.create_task_run(workspace_id,app_key, create_task_run_details=task)
print('Task Run:' + tskrun.data.key)