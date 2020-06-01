resource "oci_identity_compartment" "bds-demo-compartment" {
  #Required
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  description    = "Compartment automatically created by https://github.com/filanovskiy/terraform-oci-bds to incapsulate all resources needed to show BDS stack"
  name           = var.compartment_name

  #Optional
  freeform_tags = {
    "environment" = "bds-demo"
  }
}

output "compartment_OCID:" {
  value = oci_identity_compartment.bds-demo-compartment.id
}