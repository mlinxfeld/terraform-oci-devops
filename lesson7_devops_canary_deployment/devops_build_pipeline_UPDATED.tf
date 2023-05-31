resource "oci_devops_build_pipeline" "FoggyKitchenDevOpsProjectBuildPipeline" {
  provider     = oci.targetregion
  project_id   = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name = "FoggyKitchenDevOpsProjectBuildPipeline"
  description  = "FoggyKitchen DevOps Project Build Pipeline"
}

resource "oci_devops_build_pipeline_stage" "FoggyKitchenDevOpsProjectBuildPipelineBuildStage" {
  provider                  = oci.targetregion
  build_pipeline_id         = oci_devops_build_pipeline.FoggyKitchenDevOpsProjectBuildPipeline.id
  build_pipeline_stage_type = "BUILD"
  display_name              = "FoggyKitchenDevOpsProjectBuildPipelineBuildStage"
  description               = "FoggyKitchen DevOps Project Build Pipeline Build Stage"

  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline.FoggyKitchenDevOpsProjectBuildPipeline.id
    }
  }

  build_source_collection {
    items {
      connection_type = "DEVOPS_CODE_REPOSITORY"
      branch          = "master"
      name            = var.github_repository_name
      repository_id   = oci_devops_repository.FoggyKitchenGitHubRepository.id
      repository_url  = "https://devops.scmservice.${var.region}.oci.oraclecloud.com/namespaces/${local.ocir_namespace}/projects/${oci_devops_project.FoggyKitchenDevOpsProject.name}/repositories/${oci_devops_repository.FoggyKitchenGitHubRepository.name}"
    }
  }

  build_spec_file                    = "build_spec.yaml"
  image                              = "OL7_X86_64_STANDARD_10"
  stage_execution_timeout_in_seconds = 36000

  wait_criteria {
    wait_duration = "waitDuration"
    wait_type     = "ABSOLUTE_WAIT"
  }
}

resource "oci_devops_build_pipeline_stage" "FoggyKitchenDevOpsProjectBuildPipelineDeliverArtifactStage" {
  provider   = oci.targetregion
  depends_on = [oci_devops_build_pipeline_stage.FoggyKitchenDevOpsProjectBuildPipelineBuildStage]

  build_pipeline_id         = oci_devops_build_pipeline.FoggyKitchenDevOpsProjectBuildPipeline.id
  build_pipeline_stage_type = "DELIVER_ARTIFACT"
  display_name              = "FoggyKitchenDevOpsProjectBuildPipelineDeliverArtifactStage"
  description               = "FoggyKitchen DevOps Project Build Pipeline Deliver Artifact Stage"

  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.FoggyKitchenDevOpsProjectBuildPipelineBuildStage.id
    }
  }
  deliver_artifact_collection {
    items {
      artifact_id   = oci_devops_deploy_artifact.FoggyKitchenDevOpsProjectDeployArtifact.id
      artifact_name = "APPLICATION_DOCKER_IMAGE"
    }
  }
}

# 
# Added new stage to Build Pipeline - triggering Deploy Pipeline.
#

resource "oci_devops_build_pipeline_stage" "FoggyKitchenDevOpsProjectBuildPipelineDeployStage" {
  provider   = oci.targetregion
  depends_on = [oci_devops_build_pipeline_stage.FoggyKitchenDevOpsProjectBuildPipelineDeliverArtifactStage]

  build_pipeline_id         = oci_devops_build_pipeline.FoggyKitchenDevOpsProjectBuildPipeline.id
  build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"
  display_name              = "FoggyKitchenDevOpsProjectBuildPipelineDeployStage"

  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.FoggyKitchenDevOpsProjectBuildPipelineDeliverArtifactStage.id
    }
  }

  deploy_pipeline_id             = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
  is_pass_all_parameters_enabled = true 
}
