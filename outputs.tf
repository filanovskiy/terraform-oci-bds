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

output "compartment_OCID" {
  value = oci_identity_compartment.bds-demo-compartment.id
}

output "lb_public_ip" {
  value = oci_load_balancer.lb1.ip_address_details[0].ip_address
}

// -----------------------------------------------------------------------------------------
// Block generates file generate_tpcds_data.sh, which is used for generate TPCDS dataset
// -----------------------------------------------------------------------------------------
resource "local_file" "generate_tpcds_data" {
  content = join("", ["#!/bin/bash \n",
    "export DATA_DIR=/tmp/tpcds/text\n",
    "export ACCESS_URI_TPCDS=${oci_objectstorage_preauthrequest.bds_preauth_tpcds.access_uri}\n",
    "export END_POINT=https://objectstorage.us-ashburn-1.oraclecloud.com\n",
    "sudo kinit -kt `sudo find / -name hdfs.keytab|grep hdfs.keytab| sort|tail -1|cut -f 2` hdfs/`hostname`\n",
    "sudo hadoop fs -mkdir -p $DATA_DIR\n",
    "sudo hadoop fs -mkdir -p /user/opc\n",
    "sudo hadoop fs -chmod -R 777 $DATA_DIR\n",
    "sudo hadoop fs -chmod -R 777 /user/opc\n",
    "sudo hive -e \"DROP DATABASE IF EXISTS tpcds_csv\"\n",
    "sudo hive -e \"CREATE DATABASE IF NOT EXISTS tpcds_csv\"\n",
    "sudo docker run -it --network=host -v /run:/run -v /home/opc/opc.keytab:/home/opc/opc.keytab  -v /etc/krb5.conf:/etc/krb5.conf -v /tmp/tpcds:/tmp/tpcds -v /opt/:/opt/ -v /etc/hadoop:/etc/hadoop -v /etc/alternatives:/etc/alternatives -v /etc/hive:/etc/hive -v /etc/spark:/etc/spark iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen\n",
    "sudo hadoop fs -get $DATA_DIR $DATA_DIR\n",
    "for i in `sudo find $DATA_DIR|grep -v _SUCCESS|grep -v crc|grep txt|cut -d'/' -f5-`; do  curl -X PUT --data-binary @$DATA_DIR/$i $END_POINT$ACCESS_URI_TPCDS$i ; done\n",
    ]
  )
  filename = "userdata/generate_tpcds_data.sh"
}
// -----------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------------
// Block generates bootstrap.sh file for edge nodes
// -----------------------------------------------------------------------------------------
resource "local_file" "bootstrap" {
  depends_on          = [oci_bds_bds_instance.demo-bds]
  content = join("", ["#!/bin/bash \n",
    "source /home/opc/env.sh\n",
    "sudo chmod 400 /home/opc/.ssh/bdsKey \n",
    "sudo yum install -y dstat python36-oci-cli docker-engine snapd.x86_64 python36  python36-devel python36-setuptools \n",
    "sudo pip3 install oci\n",
    "sudo service docker start\n",
    "sudo systemctl stop firewalld\n",
    // Setup shell2http - open source tool for running shell scrips from WebUI/Rest
    "sudo docker pull msoap/shell2http\n",
    "wget https://github.com/msoap/shell2http/releases/download/1.13/shell2http-1.13.linux.amd64.tar.gz \n",
    "tar -zxf shell2http-1.13.linux.amd64.tar.gz\n",
    "sudo mv /home/opc/shell2http /usr/bin/\n",
    "sudo touch /home/opc/shell2http.out\n",
    "sudo chown opc:opc /home/opc/shell2http.out\n",
    // -----------------------------------------------------------------------------------------
    "sleep 3\n",
    "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/bdsKey $CM_IP chmod +x /home/opc/generate_tpcds_data.sh\n",
    "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/bdsKey $MN0_IP:/home/opc/opc.keytab /home/opc/opc.keytab\n",
    "nohup sudo shell2http -export-all-vars -show-errors -include-stderr -add-exit /gen_tpcds_text \"sudo -u opc ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/bdsKey opc@$CM_IP /home/opc/generate_tpcds_data.sh\" &> shell2http.out & \n",
    // Setup OCID enviroment varibles for oci cli and oci scrips
    "echo \"export OCI_CLI_AUTH=instance_principal\" >> .bash_profile\n",
    "echo \"export DCAT_OCID=${oci_datacatalog_catalog.bds_data_catalog.id}\" >> .bash_profile\n",
    "echo \"export DIS_OCID=${oci_dataintegration_workspace.bds_demo_workspace.id}\" >> .bash_profile\n",
    "echo \"export COMPARTMENT_OCID=${local.compartment_ocid}\" >> .bash_profile\n",
    "echo \"export REGION=${var.region}\" >> .bash_profile\n",
    "echo \"export TENANCY_OCID=${var.tenancy_ocid}\" >> .bash_profile\n",
    "echo \"export OS_NAMESPACE=${data.oci_objectstorage_namespace.bds-demo-namespace.namespace}\" >> .bash_profile\n",
    // -----------------------------------------------------------------------------------------
    "sudo chmod +x /home/opc/download*.sh /home/opc/dcat/dcat_stack.sh /home/opc/dcat/dcat_harvest.sh /home/opc/dis/create_df_weather.sh /home/opc/dis/dis_crete_da.sh\n",
    "/home/opc/setup-edge.sh\n",
    ]
  )
  filename = "userdata/bootstrap.sh"
}
// -----------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------