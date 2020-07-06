resource "oci_datacatalog_catalog" "bds_data_catalog" {
    #Required
    compartment_id = local.compartment_ocid
    display_name = "bds-demo-dcat"
}
