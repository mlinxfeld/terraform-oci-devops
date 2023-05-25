resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_artifacts_container_repository" "FoggyKitchenDevOpsProjectContainerRepository" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "${var.github_repository_name}-${random_id.tag.hex}"
  is_public      = true
}

resource "oci_devops_deploy_artifact" "FoggyKitchenDevOpsProjectDeployArtifact" {
  provider                   = oci.targetregion
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_type       = "DOCKER_IMAGE"
  project_id                 = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name               = oci_artifacts_container_repository.FoggyKitchenDevOpsProjectContainerRepository.display_name

  deploy_artifact_source {
    deploy_artifact_source_type = "OCIR"
    image_uri                   = "${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.FoggyKitchenDevOpsProjectContainerRepository.display_name}:0.1.0-$${BUILDRUN_HASH}"
    image_digest                = " "
    repository_id               = oci_devops_repository.FoggyKitchenGitHubRepository.id
  }
}

resource "oci_devops_deploy_artifact" "FoggyKitchenDevOpsProjectDeployHelmArtifact" {
  provider                   = oci.targetregion
  project_id                 = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name               = "FoggyKitchenDevOpsProjectDeployArtifact"
  deploy_artifact_type       = "HELM_CHART"
  argument_substitution_mode = "NONE"

  deploy_artifact_source {
    deploy_artifact_source_type = "HELM_CHART"
    chart_url                   = "oci://${local.ocir_docker_repository}/${local.ocir_namespace}/${var.helm_repo_name}/${var.release_name}/${var.release_name}"
    deploy_artifact_version     = "0.1.0"
  }
}

resource "oci_devops_deploy_artifact" "FoggyKitchenDevOpsDeployValuesYamlArtifact" {
  provider                   = oci.targetregion
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_type       = "GENERIC_FILE"
  project_id                 = oci_devops_project.FoggyKitchenDevOpsProject.id
  display_name               = "values.yaml"

  deploy_artifact_source {
    deploy_artifact_source_type = "INLINE"
    base64encoded_content       = replace(file("${path.module}/manifest/values.yaml"), "<OCIR_REPO>", "${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.FoggyKitchenDevOpsProjectContainerRepository.display_name}")
  }
}
