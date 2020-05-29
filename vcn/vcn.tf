resource oci_core_vcn bds-demo-vcn {
  cidr_block     = "10.200.0.0/16"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name  = "bds-demo-vcn"
  dns_label     = "bdsvcnnew"
  freeform_tags = {}

  #ipv6cidr_block = <<Optional value not found in discovery>>
  #is_ipv6enabled = <<Optional value not found in discovery>>
}