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

output "lb_public_ip" {
  value = oci_load_balancer.lb1.ip_address_details.ip_address
}

resource "local_file" "generate_tpcds_data" {
  content = join("", ["#!/bin/bash \n",
    "export DATA_DIR=/tmp/snap.docker/tmp/tpcds/text\n",
    "export ACCESS_URI=${oci_objectstorage_preauthrequest.bds_preauthenticated_request.access_uri} \n",
    "export END_POINT=https://objectstorage.us-ashburn-1.oraclecloud.com \n",
    "sudo docker run -v /tmp/tpcds:/tmp/tpcds iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen\n",
    //"for i in `find /tmp/tpcds/text/|grep -v _SUCCESS|grep -v crc|grep txt`; do  curl -X PUT --data-binary @$i $END_POINT$ACCESS_URI$i ; done",
    "for i in `sudo find $DATA_DIR|grep -v _SUCCESS|grep -v crc|grep txt|cut -d'/' -f7-`; do  curl -X PUT --data-binary @$DATA_DIR$i $END_POINT$ACCESS_URI$i ; done\n",
    ]
  )
  filename = "userdata/generate_tpcds_data.sh"
}

resource "local_file" "bootstrap" {
  content = join("", ["#!/bin/bash \n",
    "sudo yum install -y dstat python36-oci-cli docker-engine snapd.x86_64 \n",
    "sudo service docker start\n",
    "sudo docker pull iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen:latest\n",
    "sudo docker pull msoap/shell2http\n",
    //"sudo docker run -p 8080:8080 --rm -d msoap/shell2http -export-all-vars -add-exit -shell=\"bash\" -include-stderr -show-errors /generate_tpcds_text \"/home/opc/generate_tpcds_data.sh\" &> shell2http.out & \n",
    //"sudo systemctl start snapd.service\n",
    //"sudo snap install shell2http\n",
    "sudo systemctl stop firewalld\n",
    "wget https://github.com/msoap/shell2http/releases/download/1.13/shell2http-1.13.linux.amd64.tar.gz \n",
    "tar -zxf shell2http-1.13.linux.amd64.tar.gz\n",
    "sudo mv /home/opc/shell2http /usr/bin/\n",
    "nohup sudo shell2http -host=\"0.0.0.0\" -export-all-vars -add-exit /gen_tpcds_text \"/home/opc/generate_tpcds_data.sh\" &> shell2http.out & \n",
    ]
  )
  filename = "userdata/bootstrap.sh"
}