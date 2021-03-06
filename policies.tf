resource "oci_identity_policy" allow_bds_read_oci_resources {
  depends_on = [oci_identity_dynamic_group.bds-demo-dg]
  #Required
  provider       = oci.home
  compartment_id = local.compartment_ocid
  description    = "Policy allowed BDS access OCI components"
  name           = "bds-required.pl"
  //statements = [var.policy_allow_bds data.oci_identity_compartment.runtime_compartment.name ,]
  statements = ["allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE, VNIC_ATTACHMENT_READ, SUBNET_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage bds-instance in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage virtual-network-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow service FaaS to use virtual-network-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow service FaaS to read repos in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage repos in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //   "allow group ${oci_identity_group.bds_admin_grp.name} to use virtual-network-family in tenancy",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage functions-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to read metrics in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to read objectstorage-namespaces in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //"allow dynamic-group bds-demo-dg to manage objects in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //"allow dynamic-group bds-demo-dg to manage buckets in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //"allow dynamic-group bds-demo-dg to manage objectstorage-namespaces in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //"allow dynamic-group bds-demo-dg to manage data-catalog-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow dynamic-group bds-demo-dg to manage all-resources in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow dynamic-group bds-demo-dg to use functions-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow any-user to use functions-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    //where  ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = ${local.compartment_ocid} }",
    //   "allow group ${oci_identity_group.bds_admin_grp.name} to use cloud-shell in tenancy",
  ]
  freeform_tags = {
    "environment" = "bds-demo"
  }
}



