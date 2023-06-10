resource "oci_identity_dynamic_group" "FoggyKitchenDevOpsProjectPipelineDynamicGroup" {
  provider       = oci.homeregion
  name           = "FoggyKitchenDevOpsProjectPipelineDynamicGroup"
  description    = "FoggyKitchen DevOps Project Pipeline Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "All {resource.compartment.id = '${oci_identity_compartment.FoggyKitchenCompartment.id}', Any {resource.type = 'devopsdeploypipeline', resource.type = 'devopsbuildpipeline', resource.type = 'devopsrepository', resource.type = 'devopsconnection', resource.type = 'devopstrigger'}}"
}

resource "oci_identity_policy" "FoggyKitchenDevOpsProjectPipelinePolicy1" {
  provider       = oci.homeregion
  depends_on     = [oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup]
  name           = "FoggyKitchenDevOpsProjectPipelinePolicy1"
  description    = "FoggyKitchen DevOps Project Pipeline Policy (use/manage resources in FoggyKitchen compartment)"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  statements     = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to manage all-resources in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use ons-topics in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use adm-knowledge-bases in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use devops-family in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to manage adm-vulnerability-audits in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use subnets in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use vnics in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use network-security-groups in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to use cabundles in compartment id ${oci_identity_compartment.FoggyKitchenCompartment.id}",
  ]
}

resource "oci_identity_policy" "FoggyKitchenDevOpsProjectPipelinePolicy2" {
  provider       = oci.homeregion
  depends_on     = [oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup]
  name           = "FoggyKitchenDevOpsProjectPipelinePolicy2"
  description    = "FoggyKitchen DevOps Project Pipeline Policy (read secrets from OCI Vault in tenancy)"
  compartment_id = var.tenancy_ocid
  statements     = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to read secret-family in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenDevOpsProjectPipelineDynamicGroup.name} to read devops-family in compartment '${oci_identity_compartment.FoggyKitchenCompartment.name}'"
  ]
}
