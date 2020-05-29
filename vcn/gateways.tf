resource oci_core_service_gateway bds-demo-service-gw {
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name = "bds-demo-service-gw"
  #route_table_id = <<Optional value not found in discovery>>
  services {
    service_id = "ocid1.service.oc1.iad.aaaaaaaam4zfmy2rjue6fmglumm3czgisxzrnvrwqeodtztg7hwa272mlfna"
  }
  freeform_tags = {
    "environment" = "bds-demo"
  }
  vcn_id = oci_core_vcn.bds-demo-vcn.id
}

resource oci_core_internet_gateway bds-demo-new-ig {
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name = "bds-new-ig"
  enabled      = "true"
  freeform_tags = {
    "environment" = "bds-demo"
  }
  vcn_id = oci_core_vcn.bds-demo-vcn.id
}


resource oci_core_nat_gateway bds-demo-nat {
  block_traffic  = "true"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name = "bds-demo-nat"
  freeform_tags = {
    "environment" = "bds-demo"
  }
  vcn_id = oci_core_vcn.bds-demo-vcn.id
}