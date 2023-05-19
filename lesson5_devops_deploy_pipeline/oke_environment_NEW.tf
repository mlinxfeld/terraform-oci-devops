resource "oci_containerengine_cluster" "FoggyKitchenOKECluster" {
  count              = var.oke_target_environment ? 1 : 0
  provider           = oci.targetregion
  compartment_id     = oci_identity_compartment.FoggyKitchenCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_virtual_network.FoggyKitchenOKEVCN[0].id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.FoggyKitchenOKEAPIEndpointSubnet[0].id
    nsg_ids              = [oci_core_network_security_group.FoggyKitchenOKENSG[0].id]
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.FoggyKitchenOKELBSubnet[0].id]

    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }
  }
}

resource "oci_containerengine_node_pool" "FoggyKitchenOKENodePool" {
  count              = var.oke_target_environment ? 1 : 0
  provider           = oci.targetregion
  cluster_id         = oci_containerengine_cluster.FoggyKitchenOKECluster[0].id
  compartment_id     = oci_identity_compartment.FoggyKitchenCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = "FoggyKitchenOKENodePool"
  node_shape         = var.oke_node_shape

  node_source_details {
    image_id    = local.oracle_linux_images[0]
    source_type = "IMAGE"
    boot_volume_size_in_gbs = var.oke_node_boot_volume_size_in_gbs
  }

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus         = var.flex_shape_ocpus
    }
  }

  node_config_details {
    dynamic "placement_configs" {
      iterator = pc_iter
      for_each = data.oci_identity_availability_domains.ADs.availability_domains
      content {
        availability_domain = pc_iter.value.name
        subnet_id           = oci_core_subnet.FoggyKitchenOKENodesPodsSubnet[0].id
      }
    }
    size = var.node_pool_size
    
  }
  
  initial_node_labels {
    key   = "key"
    value = "value"
  }

  ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
}

resource "oci_devops_deploy_environment" "FoggyKitchenDevOpsOKEEnvironment" {
  count                   = var.oke_target_environment ? 1 : 0
  provider                = oci.targetregion
  display_name            = "FoggyKitchenDevOpsOKEEnvironment"
  description             = "FoggyKitchen DevOps OKE Environment"
  deploy_environment_type = "OKE_CLUSTER"
  project_id              = oci_devops_project.FoggyKitchenDevOpsProject.id
  cluster_id              = oci_containerengine_cluster.FoggyKitchenOKECluster[0].id
}
