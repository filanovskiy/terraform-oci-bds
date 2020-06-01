
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
  compartment_id = var.tenancy_ocid 
  // compartment_id = var.compartment_ocid
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_user_group_membership" "user-group-membership" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  // compartment_id = var.compartment_ocid
  user_id        = oci_identity_user.bds_admin_usr.id
  group_id       = oci_identity_group.bds_admin_grp.id

}

