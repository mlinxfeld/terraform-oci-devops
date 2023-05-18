resource "oci_core_virtual_network" "FoggyKitchenDevOpsBuildVCN" {
  provider       = oci.targetregion
  cidr_block     = lookup(var.network_cidrs, "VCN-CIDR")
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDevOpsBuildVCN"
  dns_label      = "fkvcn"
}

resource "oci_core_nat_gateway" "FoggyKitchenDevOpsBuildNATGateway" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDevOpsBuildNATGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.id
}

resource "oci_core_route_table" "FoggyKitchenDevOpsBuildVCNRouteTable" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.id
  display_name   = "FoggyKitchenVCNDevOpsBuildRouteTable"

  route_rules {
    description       = "Traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenDevOpsBuildNATGateway.id
  }
}

resource "oci_core_network_security_group" "FoggyKitchenDevOpsBuildSecurityGroup" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDevOpsBuildSecurityGroup"
  vcn_id         = oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.id
}

resource "oci_core_network_security_group_security_rule" "FoggyKitchenDevOpsBuildSecurityEgressGroupRule" {
  provider                  = oci.targetregion
  network_security_group_id = oci_core_network_security_group.FoggyKitchenDevOpsBuildSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = local.all_protocols
  destination               = lookup(var.network_cidrs, "ALL-CIDR")
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "FoggyKitchenDevOpsBuildSecurityIngressGroupSSHRule" {
  provider                  = oci.targetregion
  network_security_group_id = oci_core_network_security_group.FoggyKitchenDevOpsBuildSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol_number 
  source                    = lookup(var.network_cidrs, "ALL-CIDR")
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = local.ssh_port_number
      min = local.ssh_port_number 
    }
  }
}

resource "oci_core_subnet" "FoggyKitchenDevOpsBuildSubnet" {
  provider                   = oci.targetregion
  cidr_block                 = lookup(var.network_cidrs, "DEVOPS-BUILD-SUBNET-CIDR")
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name               = "FoggyKitchenDevOpsBuildSubnet"
  dns_label                  = "devops"
  vcn_id                     = oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenDevOpsBuildVCNRouteTable.id 
  dhcp_options_id            = oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.default_dhcp_options_id
  security_list_ids          = [oci_core_virtual_network.FoggyKitchenDevOpsBuildVCN.default_security_list_id]
}


