resource "oci_devops_connection" "FoggyKitchenGithubConnection" {
  access_token    = var.github_pat_vault_secret_id
  connection_type = "GITHUB_ACCESS_TOKEN"
  project_id      = oci_devops_project.FoggyKitchenDevOpsProject.id
  description     = "FoggyKitchenGithubConnection"
  display_name    = "FoggyKitchenGithubConnection"
}

resource "oci_devops_repository" "FoggyKitchenGitHubRepository" {
    name            = var.github_repository_name
    project_id      = oci_devops_project.FoggyKitchenDevOpsProject.id
    repository_type = "MIRRORED"
    description     = "FoggyKitchenGitHubRepository"
    
    mirror_repository_config {
        connector_id   = oci_devops_connection.FoggyKitchenGithubConnection.id
        repository_url = var.github_repository_url

        trigger_schedule {
            schedule_type   = "DEFAULT"
        }
    }
}
