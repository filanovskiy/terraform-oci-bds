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
    source      = "./edge_env.sh"
    destination = "~/edge_env.sh"
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
      # "sudo ~/generate_tpcds_data.sh",
      "sudo docker pull msoap/shell2http",
      "sudo docker run -p 8080:8080 --rm -d msoap/shell2http /generate_tpcds_text /home/opc/generate_tpcds_data",
    ]
  }
}