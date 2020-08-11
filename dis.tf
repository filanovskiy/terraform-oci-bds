resource "oci_dataintegration_workspace" "bds_demo_workspace" {
    #Required
    compartment_id = local.compartment_ocid
    display_name = "bds-demo-dis"

    #Optional
      freeform_tags = {"environment" = "bds-demo"}
    description = "DIS for Big Data Service Demo"
    //dns_server_ip = "${var.workspace_dns_server_ip}"
    //dns_server_zone = "${var.workspace_dns_server_zone}"
    is_private_network_enabled = "false"
    //subnet_id = "${oci_core_subnet.test_subnet.id}"
    //vcn_id = "${oci_core_vcn.test_vcn.id}"
}