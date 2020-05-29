
resource oci_core_default_dhcp_options bds-demo-DHCP-Options-for-bds-vcn-new {
  defined_tags = {}

  display_name  = "Default DHCP Options for bds-vcn-new"
  freeform_tags = {}

  manage_default_resource_id = oci_core_vcn.bds-demo-vcn.default_dhcp_options_id

  options {
    custom_dns_servers = []

    #search_domain_names = <<Optional value not found in discovery>>
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }

  options {
    #custom_dns_servers = <<Optional value not found in discovery>>
    search_domain_names = [
      "bdsvcnnew.oraclevcn.com",
    ]

    #server_type = <<Optional value not found in discovery>>
    type = "SearchDomain"
  }
}