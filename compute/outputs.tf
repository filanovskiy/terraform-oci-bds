data oci_core_vnic_attachments edge_node_vnics {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.US-ASHBURN-AD-1.name
  instance_id         = oci_core_instance.bds-demo-egde.id
}

data oci_core_subnet customer_subnet {
  subnet_id = var.subnet_ocid
}

data "oci_core_vnic" "edge_node_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.edge_node_vnics.vnic_attachments[0], "vnic_id")}"
}

output "public-ip" {
  value = data.oci_core_vnic.edge_node_vnic.public_ip_address
}

resource "local_file" "edge_env" {
  content = join("", ["export CLUSTER=${oci_bds_bds_instance.demo-bds.display_name} \n",
    "export MN0_HOSTNAME=${oci_bds_bds_instance.demo-bds.nodes[0].display_name} \n",
    "export MN0_IP=${oci_bds_bds_instance.demo-bds.nodes[0].ip_address} \n",
    "export CM_IP=${substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)} \n",
    "export CM_ADMIN_USER=admin \n",
    "export CM_ADMIN_PASSWORD=${base64decode(var.bds_instance_cluster_admin_password)} \n",
    "export PRIVATE_KEY=/home/opc/.ssh/bdsKey \n",
    "export SUBNET_CIDR=${data.oci_core_subnet.customer_subnet.cidr_block} \n",
    "export EDGE_IP=$(hostname -I)  \n",
    "export EDGE_HOSTNAME=$(hostname -a) \n",
    "export EDGE_FQDN=$(hostname -A) \n",
    "export ETC_HOSTS=$EDGE_IP $EDGE_FQDN $EDGE_HOSTNAME",
    ]
  )
  filename = "edge_env.sh"
}

/* output "cm_public_ip" {
  value = oci_core_public_ip.cm_public_ip.ip_address
} */

output "cm_instance_ocid" {
  value = oci_bds_bds_instance.demo-bds.nodes[2].instance_id
}

data "oci_core_private_ips" "test_private_ips_by_ip_address" {
    #Optional
    ip_address = ${substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)}
    subnet_id = var.subnet_ocid
}

output "test_private_ips_by_ip_address" {
  value = data.oci_core_private_ips.test_private_ips_by_ip_address.id
}