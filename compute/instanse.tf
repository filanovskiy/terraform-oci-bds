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


/* provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/bootstrap.sh"
    destination = "~/bootstrap.sh"
  }

provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = oci_core_public_ip.cm_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/generate_tpcds_data.sh"
    destination = "~/generate_tpcds_data.sh"
  }

provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = oci_core_public_ip.cm_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/downloadkikes.sh"
    destination = "~/downloadkikes.sh"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/generate_tpcds_data.sh"
    destination = "~/generate_tpcds_data.sh"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/env.sh"
    destination = "~/env.sh"
  }
  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/setup-edge.sh"
    destination = "~/setup-edge.sh"
  }
  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    source      = "./userdata/add-to-cm.sh"
    destination = "~/add-to-cm.sh"
  }
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
  } */

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
  } 

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }
    inline = [
      "chmod +x ~/generate_tpcds_data.sh",
      "chmod +x ~/bootstrap.sh",
      "chmod +x ~/setup-edge.sh",
      "chmod +x ~/add-to-cm.sh",
      "chmod +x ~/env.sh",
      "/home/opc/bootstrap.sh",
      "cat env.sh >> .bash_profile",
      //"scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/bdsKey $MN0_IP:/home/opc/opc.keytab /home/opc/opc.keytab",
      "echo \"* * * * * kinit -kt /home/opc/opc.keytab opc\" >> mycron",
      "crontab mycron",
      //"/home/opc/env.sh",
      //"/home/opc/setup-edge.sh",
    ]
  }
}