module "vcn" {
  source           = "./vcn"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  home_region      = var.home_region
}

module "compute" {
  source                              = "./compute"
  compartment_ocid                    = var.compartment_ocid
  tenancy_ocid                        = var.tenancy_ocid
  region                              = var.region
  ssh_public_key                      = var.ssh_public_key
  vm_image_id                         = var.vm_image_id
  bds_instance_cluster_admin_password = var.bds_instance_cluster_admin_password
  subnet_ocid                         = module.vcn.subnet_ids
}
