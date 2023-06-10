resource "oci_devops_deploy_pipeline" "FoggyKitchenDevOpsProjectDeployPipeline" {
  provider     = oci.targetregion
  project_id   = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name = "FoggyKitchenDevOpsProjectDeployPipeline"
  description  = "FoggyKitchen DevOps Project Deploy Pipeline"

  deploy_pipeline_parameters {
    items {
      name          = "namespace"
      default_value = "foggykitchen"
      description   = "foggykitchenapp"
    }
  }
}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenDeployStage" {
    provider                                = oci.targetregion
    deploy_pipeline_id                      = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type                       = "OKE_BLUE_GREEN_DEPLOYMENT"
    display_name                            = "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenDeployStage"
    description                             = "FoggyKitchen DevOps Project Deploy Pipeline BlueGreen Deploy Stage"
    
    kubernetes_manifest_deploy_artifact_ids = [
       oci_devops_deploy_artifact.FoggyKitchenDevOpsProjectKubernetesManifestArtifact.id,
    ]
    oke_cluster_deploy_environment_id       = oci_devops_deploy_environment.FoggyKitchenDevOpsOKEEnvironment[0].id
  
    blue_green_strategy {
        ingress_name  = "foggykitchen-oke-bg-app-ing"
        namespace_a   = var.deploy_stage_green_namespace
        namespace_b   = var.deploy_stage_blue_namespace
        strategy_type = "NGINX_BLUE_GREEN_STRATEGY"
    }

    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
        }
    }

}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenProductionReleaseApprovalStage" {
    provider                                 = oci.targetregion
    deploy_pipeline_id                       = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type                        = "MANUAL_APPROVAL"
    display_name                             = "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenProductionReleaseApprovalStage"
    description                              = "FoggyKitchen DevOps Project Deploy Pipeline Blue Green Production Release Approval Stage"
        
    approval_policy {
        approval_policy_type         = "COUNT_BASED_APPROVAL"
        number_of_approvals_required = var.bluegreen_prod_release_count_of_approval
    }

    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineBlueGreenDeployStage.id
        }
    }

}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenTrafficShiftStage" {
    provider                       = oci.targetregion
    deploy_pipeline_id             = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type              = "OKE_BLUE_GREEN_TRAFFIC_SHIFT"
    display_name                   = "FoggyKitchenDevOpsProjectDeployPipelineBlueGreenTrafficShiftStage"
    description                    = "FoggyKitchen DevOps Project Deploy Pipeline Blue Green Traffic Shift Stage"
    
    oke_blue_green_deploy_stage_id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineBlueGreenDeployStage.id
   
   
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineBlueGreenProductionReleaseApprovalStage.id
        }
    }
}
