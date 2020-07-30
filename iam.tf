resource "oci_identity_group" "bds_admin_grp" {
  provider       = oci.home
  name           = "bds_admin_grp"
  description    = "group for bds admins"
  compartment_id = var.tenancy_ocid
  // compartment_id = local.compartment_ocid
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_user" "bds_admin_usr" {
  provider       = oci.home
  name           = "bds_admin_usr"
  description    = "user for managing BDS"
  compartment_id = var.tenancy_ocid
  // compartment_id = local.compartment_ocid
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_user_group_membership" "user-group-membership" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  // compartment_id = local.compartment_ocid
  user_id  = oci_identity_user.bds_admin_usr.id
  group_id = oci_identity_group.bds_admin_grp.id

}

resource "oci_identity_compartment" "bds-demo-compartment" {
  #Required
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  description    = "Compartment automatically created by https://github.com/filanovskiy/terraform-oci-bds to incapsulate all resources needed to show BDS stack"
  name           = var.compartment_name
  //enable_delete = "true"

  #Optional
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

resource "oci_identity_dynamic_group" "bds-demo-dg" {
  #Required
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  description    = "$dynamic group for API gateway"
  //matching_rule  = "ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = [${local.compartment_ocid}]}"
  matching_rule  = "ALL {request.resource.compartment.id = [${local.compartment_ocid}]}"
  name           = "api-gw-dg"
  #Optional
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_identity_ui_password" "user_ui_password" {
  provider = oci.home
  #Required
  user_id = oci_identity_user.bds_admin_usr.id
}