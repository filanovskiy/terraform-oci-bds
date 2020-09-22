resource "oci_datacatalog_catalog" "bds_data_catalog" {
    #Required
    compartment_id = local.compartment_ocid
    display_name = "bds-demo-dcat"
}
// -----------------------------------------------------------------------------------------
// Generate file for Create Connection
// -----------------------------------------------------------------------------------------
resource "local_file" "dcat_create_connection" {
  content = join("", ["{\"isDefault\": \"true\", \"typeKey\": \"cbb356cc-3b00-43c4-b74c-f9f146fc68a9\", \"displayName\": \"obj_st_connection\",\"description\": \"Connection to Obj Store\",\"encProperties\": {\"default\": {}},\"properties\": {\"default\": {\"ociRegion\": \"${var.region}\",\"ociCompartment\": \"${local.compartment_ocid}\"}}}",
  ])
  filename = "userdata/dcat/create_connection.json"
}
// -----------------------------------------------------------------------------------------
// Generate file for Data Asset creation
// -----------------------------------------------------------------------------------------
resource "local_file" "dcat_create_data_asset" {
  content = join("", ["{\"displayName\": \"BDS_DEMO_DATA_ASSET\",\"typeKey\": \"3ea65bc5-f60d-477a-a591-f063665339f9\",\"properties\": {\"default\": {\"url\": \"https://swiftobjectstorage.${var.region}.oraclecloud.com\",\"namespace\": \"${data.oci_objectstorage_namespace.bds-demo-namespace.namespace}\"}}}",
  ])
  filename = "userdata/dcat/create_data_asset.json"
}