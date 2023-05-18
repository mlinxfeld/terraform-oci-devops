resource "oci_devops_build_pipeline" "FoggyKitchenDevOpsProjectBuildPipeline" {
  provider     = oci.targetregion
  project_id   = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name = "FoggyKitchenDevOpsProjectBuildPipeline"
  description  = "FoggyKitchen DevOps Project Build Pipeline"
}
