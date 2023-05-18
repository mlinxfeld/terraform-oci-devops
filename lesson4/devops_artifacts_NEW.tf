resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_artifacts_container_repository" "FoggyKitchenDevOpsProjectContainerRepository" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "${var.github_repository_name}-${random_id.tag.hex}"
  is_public      = true
}
