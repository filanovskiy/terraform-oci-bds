resource oci_core_default_security_list bds-demo-security-list {

  display_name = "Default Security List for bds-demo"

  egress_security_rules {
    #description = <<Optional value not found in discovery>>
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    #icmp_options = <<Optional value not found in discovery>>
    protocol  = "all"
    stateless = "false"

    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }

  freeform_tags = {
    "environment" = "bds-demo"
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "22"
      min = "22"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

   ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "443"
      min = "443"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }


  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "4"
      type = "3"
    }

    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "-1"
      type = "3"
    }

    protocol    = "1"
    source      = "10.200.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7180"
      min = "7180"

      source_port_range {
        max = "7180"
        min = "7180"
      }
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "8890"
      min = "8888"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

ingress_security_rules {
    description = "Port for RStudio server"
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "8787"
      min = "8787"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "8090"
      min = "8090"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "18088"
      min = "18088"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7183"
      min = "7183"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7182"
      min = "7182"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7180"
      min = "7180"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "1521"
      min = "1521"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "30000"
      min = "30000"

    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "8088"
      min = "8088"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "80"
      min = "80"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    description = "Port opened for Zeppelin"

    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "8080"
      min = "8080"

      #source_port_range = <<Optional value not found in discovery>>
    }

    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    description = "Open all intersubnet ports"

    #icmp_options = <<Optional value not found in discovery>>
    //protocol    = "ALL"
    protocol    = all
    source      = "10.200.0.0/17"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    //tcp_options {
//      max = "65535"
  //    min = "1"

      #source_port_range = <<Optional value not found in discovery>>
    //}

    #udp_options = <<Optional value not found in discovery>>
  }

  manage_default_resource_id = oci_core_vcn.bds-demo-vcn.default_security_list_id
}