data oci_core_vnic_attachments edge_node_vnics {
  count  = local.number_edge_nodes
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.US-ASHBURN-AD-1.name
  instance_id         = oci_core_instance.bds-demo-egde[count.index].id
}

/* output "edge_node_vnics" {
  value = data.oci_core_vnic.edge_node_vnic[*]
} */

data "oci_core_vnic" "edge_node_vnic" {
  count  = local.number_edge_nodes
  vnic_id = "${lookup(data.oci_core_vnic_attachments.edge_node_vnics[count.index].vnic_attachments[0], "vnic_id")}"
}

output "public-ip" {
  value = data.oci_core_vnic.edge_node_vnic[*].public_ip_address
}

data oci_core_subnet customer_subnet {
  subnet_id = var.subnet_ocid
}
resource "local_file" "edge_env" {
  content = join("", ["#!/bin/bash \n",
    "export CLUSTER=\"${oci_bds_bds_instance.demo-bds.display_name}\"\n",
    "export MN0_HOSTNAME=${oci_bds_bds_instance.demo-bds.nodes[0].display_name}\n",
    "export MN0_IP=${oci_bds_bds_instance.demo-bds.nodes[0].ip_address} \n",
    "export MN1_IP=${oci_bds_bds_instance.demo-bds.nodes[1].ip_address} \n",
    "export UN0_IP=${oci_bds_bds_instance.demo-bds.nodes[2].ip_address} \n",
    "export UN1_IP=${oci_bds_bds_instance.demo-bds.nodes[3].ip_address} \n",
    "export CM_IP=${substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)}\n",
    "export CM_ADMIN_USER=admin\n",
    "export CM_ADMIN_PASSWORD=${base64decode(var.bds_instance_cluster_admin_password)}\n",
    "export PRIVATE_KEY=/home/opc/.ssh/bdsKey\n",
    "export SUBNET_CIDR=${data.oci_core_subnet.customer_subnet.cidr_block}\n",
    "export EDGE_IP=$(hostname -i)\n",
    "export EDGE_HOSTNAME=$(hostname -a)\n",
    "export EDGE_FQDN=$(hostname -f)\n",
    "export ETC_HOSTS=\"$EDGE_IP $EDGE_FQDN $EDGE_HOSTNAME\"",
    ]
  )
  filename = "userdata/env.sh"
}

output "cm_public_ip" {
  value = oci_core_public_ip.cm_public_ip.ip_address
}

output "cm_instance_ocid" {
  value = oci_bds_bds_instance.demo-bds.nodes[2].instance_id
  //value=oci_bds_bds_instance.demo-bds
}