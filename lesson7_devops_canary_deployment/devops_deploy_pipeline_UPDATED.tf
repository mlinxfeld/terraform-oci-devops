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


resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineCanaryDeployStage" {
    provider                                = oci.targetregion
    deploy_pipeline_id                      = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type                       = "OKE_CANARY_DEPLOYMENT"
    display_name                            = "FoggyKitchenDevOpsProjectDeployPipelineCanaryDeployStage"
    description                             = "FoggyKitchen DevOps Project Deploy Pipeline Canary Deploy Stage"
    kubernetes_manifest_deploy_artifact_ids = [
        oci_devops_deploy_artifact.FoggyKitchenDevOpsProjectKubernetesManifestArtifact.id,
    ]
    oke_cluster_deploy_environment_id       = oci_devops_deploy_environment.FoggyKitchenDevOpsOKEEnvironment[0].id
          
    canary_strategy  {
        ingress_name  = "foggykitchen-oke-canary-app-ing"
        namespace     = var.deploy_stage_canary_namespace
        strategy_type = "NGINX_CANARY_STRATEGY"
    }

    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
        }
    }

}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineCanaryTrafficShiftStage" {
    provider                   = oci.targetregion
    deploy_pipeline_id         = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type          = "OKE_CANARY_TRAFFIC_SHIFT"
    display_name               = "FoggyKitchenDevOpsProjectDeployPipelineCanaryTrafficShiftStage"
    description                = "FoggyKitchen DevOps Project Deploy Pipeline Canary Traffic Shift Stage"
    oke_canary_deploy_stage_id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineCanaryDeployStage.id
    
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineCanaryDeployStage.id
        }
    }

    rollout_policy {
        batch_count            = 1
        batch_delay_in_seconds = 60
        batch_percentage       = 0
        ramp_limit_percent     = var.percentage_canary_shift
    }

}


resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineCanaryProductionReleaseApprovalStage" {
    provider                                 = oci.targetregion
    deploy_pipeline_id                       = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type                        = "OKE_CANARY_APPROVAL"
    display_name                             = "FoggyKitchenDevOpsProjectDeployPipelineCanaryProductionReleaseApprovalStage"
    description                              = "FoggyKitchen DevOps Project Deploy Pipeline Canary Production Release Approval Stage"
    oke_canary_traffic_shift_deploy_stage_id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineCanaryTrafficShiftStage.id
        
    approval_policy {
        approval_policy_type         = "COUNT_BASED_APPROVAL"
        number_of_approvals_required = var.canary_prod_release_count_of_approval
    }

    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineCanaryTrafficShiftStage.id
        }
    }

}

resource "oci_devops_deploy_stage" "FoggyKitchenDevOpsProjectDeployPipelineCanaryProductionReleaseStage" {
    provider                                = oci.targetregion
    deploy_pipeline_id                      = oci_devops_deploy_pipeline.FoggyKitchenDevOpsProjectDeployPipeline.id
    deploy_stage_type                       = "OKE_DEPLOYMENT"
    display_name                            = "FoggyKitchenDevOpsProjectDeployPipelineCanaryProductionReleaseStage"
    description                             = "FoggyKitchen DevOps Project Deploy Pipeline Canary Production Release Stage"
    kubernetes_manifest_deploy_artifact_ids = [
        oci_devops_deploy_artifact.FoggyKitchenDevOpsProjectKubernetesManifestArtifact.id,
    ]
    namespace                               = var.deploy_stage_prod_namespace
    oke_cluster_deploy_environment_id       = oci_devops_deploy_environment.FoggyKitchenDevOpsOKEEnvironment[0].id
       

    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.FoggyKitchenDevOpsProjectDeployPipelineCanaryProductionReleaseApprovalStage.id
        }
    }

    rollback_policy {
        policy_type = "AUTOMATED_STAGE_ROLLBACK_POLICY"
    }

}
