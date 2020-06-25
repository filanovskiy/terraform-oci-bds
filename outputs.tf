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

output "cm_public_ip" {
  value = module.compute.cm_public_ip
}

output "cm_instance_ocid" {
  value = module.compute.cm_instance_ocid
}

output "compartment_OCID" {
  value = oci_identity_compartment.bds-demo-compartment.id
}

resource "local_file" "generate_tpcds_data" {
  content = join("", ["#!/bin/bash \n",
    "export ACCESS_URI=${oci_objectstorage_preauthrequest.bds_preauthenticated_request.access_uri} \n",
    "export END_POINT=https://objectstorage.us-ashburn-1.oraclecloud.com \n",
    "sudo docker run -v /tmp/tpcds:/tmp/tpcds iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen\n",
    "for i in `find /tmp/tpcds/text/|grep -v _SUCCESS|grep -v crc|grep txt`; do  curl -X PUT --data-binary @$i $END_POINT$ACCESS_URI$i ; done",
    ]
  )
  filename = "userdata/generate_tpcds_data.sh"
}

resource "local_file" "bootstrap" {
  content = join("", ["#!/bin/bash \n",
    "sudo yum install -y dstat python36-oci-cli docker-engine \n",
    "sudo service docker start\n",
    "sudo docker pull iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen:latest\n",
    "sudo docker pull msoap/shell2http\n",
    "sudo docker run -p 8080:8080 --rm -d msoap/shell2http /generate_tpcds_text /home/opc/generate_tpcds_data.sh\n",
    ]
  )
  filename = "userdata/bootstrap.sh"
}