module "vcn" {
  source           = "./vcn"
  compartment_ocid = oci_identity_compartment.bds-demo-compartment.id
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  home_region      = var.home_region
}

module "compute" {
  source                              = "./compute"
  ssh_keys_prefix                     = var.ssh_keys_prefix
  ssh_private_key                     = var.ssh_private_key
  compartment_ocid                    = oci_identity_compartment.bds-demo-compartment.id
  tenancy_ocid                        = var.tenancy_ocid
  region                              = var.region
  ssh_public_key                      = var.ssh_public_key
  vm_image_id                         = var.vm_image_id
  bds_instance_cluster_admin_password = var.bds_instance_cluster_admin_password
  subnet_ocid                         = module.vcn.subnet_ids
}

locals {
  compartment_ocid = oci_identity_compartment.bds-demo-compartment.id
}
