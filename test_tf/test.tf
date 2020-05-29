provider "oci" {
  region               = "us-ashburn-1"
  private_key_password = "welcome1"
}

variable compartment_ocid {
  default = "ocid1.compartment.oc1..aaaaaaaaqfrh6ndx3miiikntt4ih5v252c5l3o24qbj7mjsaqcoilwss52oq"
}

data oci_identity_availability_domain US-ASHBURN-AD-1 {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaazo7h6yqgac7aunojr2tjsxux3ipdyamc3fgkvz7lubvdtsjyf4gq"
  ad_number      = "1"
}

data "oci_bds_bds_instance" "test_bds_instance" {
    #Required
    bds_instance_id = "ocid1.bigdataservice.oc1.iad.amaaaaaapvq3y5aasvaprf4c4fcfhrfv4mtlaboiewx2zffpx725ydoy6wgq"
}

data oci_core_subnet customer_subnet{
subnet_id="ocid1.subnet.oc1.iad.aaaaaaaafxeedic44dsd7hklhgyby5mm4mwliba62xbis4ujo2wzekrzjita"
}

output customer_subnet {
  value=data.oci_core_subnet.customer_subnet.cidr_block
}


output "bds_cluster_name" {
  value = data.oci_bds_bds_instance.test_bds_instance.display_name
}

output "bds_cluster_mn0_name" {
  value = data.oci_bds_bds_instance.test_bds_instance.nodes[0].display_name
}

output "bds_cluster_mn0_ip" {
  value = data.oci_bds_bds_instance.test_bds_instance.nodes[0].ip_address
}

output "bds_cluster_cm_ip" {
  value = substr(data.oci_bds_bds_instance.test_bds_instance.cluster_details[0].cloudera_manager_url,8,length(data.oci_bds_bds_instance.test_bds_instance.cluster_details[0].cloudera_manager_url)-13)
  //value = data.oci_bds_bds_instance.test_bds_instance.cluster_details[0].cloudera_manager_url
}
/* output "bds_cluster_utility_node_ip" {
  //value = tostring(matchkeys(data.oci_bds_bds_instance.test_bds_instance.nodes[*].ip_address,data.oci_bds_bds_instance.test_bds_instance.nodes[*].display_name,["bdsdemoun0"]))
  value = data.oci_bds_bds_instance.test_bds_instance.*
} */