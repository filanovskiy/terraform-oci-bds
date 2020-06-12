data oci_identity_compartment runtime_compartment {
  id = local.compartment_ocid
}

output "resource_compartment_name" {
  value = data.oci_identity_compartment.runtime_compartment.name
}

output "edge_node_ip" {
  value = module.compute.public-ip
}

output "user_name" {
  value = "bds_admin_usr"
}

output "bds_admin_usr_one_time_password" {
  value = oci_identity_ui_password.user_ui_password.password
}

output "test_private_ips_by_ip_address" {
  value = module.compute.test_private_ips_by_ip_address
}

output "cm_instance_ocid" {
  value = module.compute.cm_instance_ocid
}