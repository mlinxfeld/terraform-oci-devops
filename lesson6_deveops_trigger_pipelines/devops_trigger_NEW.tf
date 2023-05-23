resource "oci_devops_trigger" "FoggyKitchenDevOpsProjectTrigger" {
   count = var.pipeline_trigger ? 1 : 0  
   actions {
      build_pipeline_id = oci_devops_build_pipeline.FoggyKitchenDevOpsProjectBuildPipeline.id
      type = "TRIGGER_BUILD_PIPELINE"

      filter {
         trigger_source = "DEVOPS_CODE_REPOSITORY"
         events = ["PUSH"]

         include {
            head_ref = var.triggering_branch 
            repository_name = oci_devops_repository.FoggyKitchenGitHubRepository.name
          }
       }
    }

    project_id = oci_devops_project.FoggyKitchenDevOpsProject.id
    trigger_source = "DEVOPS_CODE_REPOSITORY"

    description = "FoggyKitchenDevOpsProjectTrigger"
    display_name = "FoggyKitchenDevOpsProjectTrigger"
    repository_id = oci_devops_repository.FoggyKitchenGitHubRepository.id
}
