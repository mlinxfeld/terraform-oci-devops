resource "oci_devops_project" "FoggyKitchenDevOpsProject" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  name           = "FoggyKitchenDevOpsProject"
  description    = "FoggyKitchen DevOps Project"
  
  notification_config {
    topic_id = oci_ons_notification_topic.FoggyKitchenDevOpsNotificationTopic.id
  }
}

resource "oci_logging_log_group" "FoggyKitchenDevOpsProjectLogGroup" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDevOpsProjectLogGroup"
}

resource "oci_logging_log" "FoggyKitchenDevOpsProjectLog" {
  provider       = oci.targetregion
  display_name   = "FoggyKitchenDevOpsProjectLog"
  log_group_id   = oci_logging_log_group.FoggyKitchenDevOpsProjectLogGroup.id
  log_type       = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_devops_project.FoggyKitchenDevOpsProject.id
      service     = "devops"
      source_type = "OCISERVICE"
    }

    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  }

  is_enabled         = true
  retention_duration = var.project_logging_config_retention_period_in_days
}

resource "oci_ons_notification_topic" "FoggyKitchenDevOpsNotificationTopic" {
  provider       = oci.targetregion
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  name           = "FoggyKitchenDevOpsNotificationTopic"
}
