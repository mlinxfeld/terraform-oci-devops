resource "oci_devops_deploy_pipeline" "FoggyKitchenDevOpsProjectDeployPipeline" {
  provider     = oci.targetregion
  project_id   = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name = "FoggyKitchenDevOpsProjectDeployPipeline"
  description  = "FoggyKitchen DevOps Project Deploy Pipeline"

  deploy_pipeline_parameters {
    items {
      name          = "BUILDRUN_HASH"
      default_value = ""
      description   = ""
    }
  }
}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineHelmStage" {
  count              = var.oke_target_environment ? 1 : 0
  provider           = oci.targetregion
  deploy_pipeline_id = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
  
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    }
  }
  
  display_name                      = "FoggyKitchenDevOpsProjectDeployPipelineHelmStage"
  description                       = "FoggyKitchen DevOps Project Deploy Pipeline Helm Stage"
  deploy_stage_type                 = "OKE_HELM_CHART_DEPLOYMENT"
  release_name                      = var.release_name
  values_artifact_ids               = [oci_devops_deploy_artifact.FoggyKitchenDevOpsDeployValuesYamlArtifact.id]
  helm_chart_deploy_artifact_id     = oci_devops_deploy_artifact.FoggyKitchenDevOpsProjectDeployHelmArtifact.id
  oke_cluster_deploy_environment_id = oci_devops_deploy_environment.FoggyKitchenDevOpsOKEEnvironment[0].id
}


