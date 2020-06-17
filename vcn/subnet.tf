resource oci_core_subnet bds-demo-subnet {
  #availability_domain = <<Optional value not found in discovery>>
  cidr_block     = "10.200.0.0/17"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  dhcp_options_id = oci_core_vcn.bds-demo-vcn.default_dhcp_options_id
  display_name    = "bds-demo-subnet"
  dns_label       = "bdsnew"

  #ipv6cidr_block = <<Optional value not found in discovery>>
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.bds-demo-vcn.default_route_table_id

  security_list_ids = [
    oci_core_vcn.bds-demo-vcn.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.bds-demo-vcn.id
  freeform_tags = {
    "environment" = "bds-demo"
  }
}