resource "oci_identity_policy" allow_bds_read_oci_resources {
  #Required
  provider       = oci.home
  compartment_id = var.compartment_ocid
  description    = "Policy allowed BDS access OCI components"
  name           = "bds-required.pl"
  //statements = [var.policy_allow_bds data.oci_identity_compartment.runtime_compartment.name ,]
  statements = ["allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE, VNIC_ATTACHMENT_READ, SUBNET_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
    "allow group ${oci_identity_group.bds_admin_grp.name} to manage bds-instance in compartment ${data.oci_identity_compartment.runtime_compartment.name}",
  "allow group  ${oci_identity_group.bds_admin_grp.name} to manage virtual-network-family in compartment ${data.oci_identity_compartment.runtime_compartment.name}", ]
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_group" "bds_admin_grp" {
  provider       = oci.home
  name           = "bds_admin_grp"
  description    = "group for bds admins"
  compartment_id = var.tenancy_ocid
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_user" "bds_admin_usr" {
  provider    = oci.home
  name        = "bds_admin_usr"
  description = "user for managing BDS"
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_user_group_membership" "user-group-membership" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  user_id        = oci_identity_user.bds_admin_usr.id
  group_id       = oci_identity_group.bds_admin_grp.id

}
