resource "oci_core_virtual_network" "FoggyKitchenOKEVCN" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  cidr_block     = lookup(var.network_cidrs, "VCN-CIDR")
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKEVCN"
  dns_label      = "fkvcn"
}

resource "oci_core_nat_gateway" "FoggyKitchenOKENATGateway" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  block_traffic  = "false"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKENATGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
}

resource "oci_core_internet_gateway" "FoggyKitchenOKEInternetGateway" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKEInternetGateway"
  enabled        = true
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
}

resource "oci_core_service_gateway" "FoggyKitchenOKEServiceGateway" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKEServiceGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  services {
    service_id = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "id")
  }
}

resource "oci_core_route_table" "FoggyKitchenOKEVCNPrivateRouteTable" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  display_name   = "FoggyKitchenOKEVCNPrivateRouteTable"

  route_rules {
    description       = "Traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenOKENATGateway[0].id
  }
  route_rules {
    description       = "Traffic to OCI services"
    destination       = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.FoggyKitchenOKEServiceGateway[0].id
  }
}

resource "oci_core_route_table" "FoggyKitchenOKEVCNPublicRouteTable" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  display_name   = "FoggyKitchenOKEVCNPublicRouteTable"

  route_rules {
    description       = "Traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenOKEInternetGateway[0].id
  }
}

resource "oci_core_security_list" "FoggyKitchenOKENodesSecurityList" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKENodesSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id

  # Ingress
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    source      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.all_protocols
    stateless   = false
  }

  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    source      = lookup(var.network_cidrs, "VCN-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.ssh_port_number
      min = local.ssh_port_number
    }
  }

  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    source      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false
  }

  ingress_security_rules {
    description = "Path discovery"
    source      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol_number
    stateless   = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  # Egress
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }

  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }

  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }

  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.oke_api_endpoint_port_number
      min = local.oke_api_endpoint_port_number
    }
  }

  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.oke_nodes_to_control_plane_port_number
      min = local.oke_nodes_to_control_plane_port_number
    }
  }

  egress_security_rules {
    description      = "Path discovery"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

}

resource "oci_core_security_list" "FoggyKitchenOKELBSecurityList" {
  count          = !var.lb_nsg && var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKELBSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id

  # Ingress

  ingress_security_rules {
    description = "External access to Load Balancer in K8S"
    source      = lookup(var.network_cidrs, "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.lb_listener_port
      min = local.lb_listener_port
    }
  }

  # Egress

  egress_security_rules {
    description      = "Allow traffic to Kubernetes Worker Nodes"
    destination      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.oke_nodes_max_port
      min = local.oke_nodes_min_port
    }
  }

}

# OKE LB NSG
resource "oci_core_network_security_group" "FoggyKitchenOKELBSecurityGroup" {
  count          = var.lb_nsg && var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenLBSecurityGroup"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
}

# OKE LB NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "FoggyKitchenOKELBSecurityEgressGroupRule" {
  count                     = var.lb_nsg && var.oke_target_environment ? 1 : 0
  provider                  = oci.targetregion
  network_security_group_id = oci_core_network_security_group.FoggyKitchenOKELBSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = local.tcp_protocol_number
  destination               = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = local.oke_nodes_max_port
      min = local.oke_nodes_min_port
    }
  }
}

# OKE LB NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "FoggyKitchenOKELBSecurityIngressGroupRules" {
  count                     = var.lb_nsg && var.oke_target_environment ? 1 : 0
  provider                  = oci.targetregion
  network_security_group_id = oci_core_network_security_group.FoggyKitchenOKELBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol_number
  source                    = lookup(var.network_cidrs, "ALL-CIDR")
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = local.lb_listener_port
      min = local.lb_listener_port
    }
  }
}


resource "oci_core_security_list" "FoggyKitchenOKEAPIEndpointSecurityList" {
  count          = var.oke_target_environment ? 1 : 0
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKEAPIEndpointSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id

  # Ingress

  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    source      = lookup(var.network_cidrs, "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.oke_api_endpoint_port_number
      min = local.oke_api_endpoint_port_number
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    source      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.oke_api_endpoint_port_number
      min = local.oke_api_endpoint_port_number
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    source      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.oke_nodes_to_control_plane_port_number
      min = local.oke_nodes_to_control_plane_port_number
    }
  }

  ingress_security_rules {
    description = "Path discovery"
    source      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol_number
    stateless   = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  # Egress

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }

  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false
  }

  egress_security_rules {
    description      = "Path discovery"
    destination      = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

}

resource "oci_core_network_security_group" "FoggyKitchenOKENSG" {
    count          = var.oke_target_environment ? 1 : 0
    provider       = oci.targetregion
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    vcn_id         = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
}

resource "oci_core_network_security_group_security_rule" "FoggyKitchenOKENSGRule6443" {
    count                     = var.oke_target_environment ? 1 : 0
    provider                  = oci.targetregion
    network_security_group_id = oci_core_network_security_group.FoggyKitchenOKENSG[0].id
    direction                 = "INGRESS"
    protocol                  = "6"

    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    stateless                 = false
    tcp_options {
        destination_port_range {
            max = "6443"
            min = "6443"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "FoggyKitchenOKENSGRule12250" {
    count                     = var.oke_target_environment ? 1 : 0
    provider                  = oci.targetregion
    network_security_group_id = oci_core_network_security_group.FoggyKitchenOKENSG[0].id
    direction                 = "INGRESS"
    protocol                  = "6"

    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    stateless                 = false
    tcp_options {
        destination_port_range {
            max = "12250"
            min = "12250"
        }
    }
}

resource "oci_core_subnet" "FoggyKitchenOKEAPIEndpointSubnet" {
  count                      = var.oke_target_environment ? 1 : 0
  provider                   = oci.targetregion
  cidr_block                 = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name               = "FoggyKitchenOKEAPIEndpointSubnet"
  dns_label                  = "endpsub"
  vcn_id                     = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.FoggyKitchenOKEVCNPublicRouteTable[0].id
  dhcp_options_id            = oci_core_virtual_network.FoggyKitchenOKEVCN[0].default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.FoggyKitchenOKEAPIEndpointSecurityList[0].id]
}

resource "oci_core_subnet" "FoggyKitchenOKENodesPodsSubnet" {
  count                      = var.oke_target_environment ? 1 : 0
  provider                   = oci.targetregion
  cidr_block                 = lookup(var.network_cidrs, "NODES-PODS-SUBNET-REGIONAL-CIDR")
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name               = "FoggyKitchenOKENodesPodsSubnet"
  dns_label                  = "nodessub"
  vcn_id                     = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.FoggyKitchenOKEVCNPrivateRouteTable[0].id
  dhcp_options_id            = oci_core_virtual_network.FoggyKitchenOKEVCN[0].default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.FoggyKitchenOKENodesSecurityList[0].id]
}

resource "oci_core_subnet" "FoggyKitchenOKELBSubnet" {
  count                      = var.oke_target_environment ? 1 : 0
  provider                   = oci.targetregion
  cidr_block                 = lookup(var.network_cidrs, "LB-SUBNET-REGIONAL-CIDR")
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name               = "FoggyKitchenOKELBSubnet"
  dns_label                  = "lbsub"
  vcn_id                     = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.FoggyKitchenOKEVCNPublicRouteTable[0].id
  dhcp_options_id            = oci_core_virtual_network.FoggyKitchenOKEVCN[0].default_dhcp_options_id
  security_list_ids          = var.lb_nsg ? null : [oci_core_security_list.FoggyKitchenOKELBSecurityList[0].id]
}


