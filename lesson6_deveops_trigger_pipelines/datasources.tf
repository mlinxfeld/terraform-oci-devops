data "oci_identity_region_subscriptions" "home_region_subscriptions" {

  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_identity_regions" "oci_regions" {
  provider   = oci.homeregion
  filter {
    name   = "name"
    values = [var.region]
  }

}

data "oci_objectstorage_namespace" "objectstorage_namespace" {
  compartment_id = var.tenancy_ocid
}

data "oci_secrets_secretbundle" "FoggyKitchenSecretBundle" {
  provider   = oci.targetregion
  secret_id  = var.ocir_vault_secret_id
}

data "oci_containerengine_cluster_option" "FoggyKitchenOKEClusterOption" {
  count             = var.oke_target_environment ? 1 : 0
  provider          = oci.targetregion
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "FoggyKitchenOKEClusterNodePoolOption" {
  count               = var.oke_target_environment ? 1 : 0
  provider            = oci.targetregion
  node_pool_option_id = "all"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  provider       = oci.targetregion
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "FoggyKitchenAllOCIServices" {
  provider       = oci.targetregion

  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
