resource "oci_identity_policy" allow_bds_read_oci_resources {
  #Required
  provider       = oci.home
  compartment_id = local.compartment_ocid
  description    = "Policy allowed BDS access OCI components"
  name           = "bds-required.pl"
  //statements = [var.policy_allow_bds data.oci_identity_compartment.runtime_compartment.name ,]
  statements = ["allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE, VNIC_ATTACHMENT_READ, SUBNET_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage bds-instance in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage virtual-network-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage repos in tenancy",
    "allow group ${oci_identity_group.bds_admin_grp.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage functions-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to read metrics in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to read objectstorage-namespaces in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to use cloud-shell in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
  ]
  freeform_tags = {
    "environment" = "bds-demo"
  }
}