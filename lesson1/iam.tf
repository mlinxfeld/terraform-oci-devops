resource "oci_identity_dynamic_group" "FoggyKitchenDevOpsProjectPipelineDynamicGroup" {
  provider       = oci.homeregion
  name           = "FoggyKitchenDevOpsProjectPipelineDynamicGroup"
  description    = "FoggyKitchen DevOps Project Pipeline Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "All {resource.type = 'devopsdeploypipeline', resource.compartment.id = '${oci_identity_compartment.FoggyKitchenCompartment.id}'}"
}

resource "oci_identity_policy" "FoggyKitchenDevOpsProjectPipelinePolicy" {
  provider       = oci.homeregion
  depends_on     = [oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup]
  name           = "FoggyKitchenDevOpsProjectPipelinePolicy"
  description    = "FoggyKitchen DevOps Project Pipeline Policy"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  statements     = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to manage all-resources in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}"
  ]
}
