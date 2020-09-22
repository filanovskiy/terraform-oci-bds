resource oci_core_instance bds-demo-egde {
  depends_on          = [oci_bds_bds_instance.demo-bds]
  availability_domain = data.oci_identity_availability_domain.US-ASHBURN-AD-1.name

  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
  }
  compartment_id = var.compartment_ocid
  create_vnic_details {
    assign_public_ip       = "true"
    display_name           = "bds-demo-egde${count.index}"
    hostname_label         = "bds-demo-egde${count.index}"
    nsg_ids                = []
    skip_source_dest_check = "false"
    subnet_id              = var.subnet_ocid
  }
  count        = local.number_edge_nodes
  display_name = "bds-demo-egde${count.index}"
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = "true"
    network_type            = "VFIO"
    remote_data_volume_type = "PARAVIRTUALIZED"
  }

  metadata = {
    "ssh_authorized_keys" = var.ssh_public_key
  }
  #preserve_boot_volume = <<Optional value not found in discovery>>
  shape = "VM.Standard2.1"

  shape_config {
    ocpus = "1"
  }

  source_details {
    source_id   = var.vm_image_id[var.region]
    source_type = "image"
  }
  state = "RUNNING"

  freeform_tags = {
    "environment" = "bds-demo"
  }

// Add private ssh key for BDS on edge node
provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = var.ssh_keys_prefix
    destination = "~/.ssh/bdsKey"
  }

/* 
// Add everything from "userdata" directory into Cloudera Manager host
provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = oci_core_public_ip.cm_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/"
    destination = "~"
  } 

// Add everything from "userdata" directory into Master Node
  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = oci_core_public_ip.mn_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/"
    destination = "~"
  }

// Add everything from "userdata" directory into edge nodes
provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/"
    destination = "~"
  }  */

// Add everything from "userdata" directory into edge nodes, Master node, Cloudera Manager node
provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = element(list(self.public_ip, oci_core_public_ip.cm_public_ip.ip_address, oci_core_public_ip.mn_public_ip.ip_address), count.index)
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/"
    destination = "~"
  } 


// Run bootstrap scrips commands on the edge nodes
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    inline = [
      // Add execution permission for bunch of files
      "chmod +x ~/generate_tpcds_data.sh ~/bootstrap.sh ~/setup-edge.sh ~/add-to-cm.sh ~/env.sh",
      // Run bootstrap.sh script, which been auto-generateed into outputs.tf
      "/home/opc/bootstrap.sh",
      // Add enviroment varibles, env.sh was autogenerated into compute/outputs.tf
      "cat env.sh >> .bash_profile",
      // Add autorefresh for opc credentials into crontab
      "echo \"* * * * * kinit -kt /home/opc/opc.keytab opc\" >> mycron",
      "crontab mycron",
    ]
  }
}