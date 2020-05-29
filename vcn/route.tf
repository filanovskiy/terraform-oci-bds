resource oci_core_default_route_table bds-demo-Route-Table {
  defined_tags = {}

  display_name  = "bds-demo-Route-Table"
  freeform_tags = {}

  manage_default_resource_id = oci_core_vcn.bds-demo-vcn.default_route_table_id

  route_rules {
    #description = <<Optional value not found in discovery>>
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.bds-demo-new-ig.id
  }

  route_rules {
    #description = <<Optional value not found in discovery>>
    destination       = "oci-iad-objectstorage"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.bds-demo-service-gw.id
  }
}