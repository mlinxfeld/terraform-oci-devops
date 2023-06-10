variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                        = "10.20.0.0/16"
    NODES-PODS-SUBNET-REGIONAL-CIDR = "10.20.30.0/24"
    LB-SUBNET-REGIONAL-CIDR         = "10.20.20.0/24"
    ENDPOINT-SUBNET-REGIONAL-CIDR   = "10.20.10.0/28"
    ALL-CIDR                        = "0.0.0.0/0"
  }
}

variable "lb_nsg" {
  default = true
}

variable "lb_listener_port" {
  default = 80
}

variable "project_logging_config_retention_period_in_days" {
  default = 30
}

variable "github_pat_vault_secret_id" {
  default = ""
}

variable "ocir_vault_secret_id" {
  default = ""
}

variable "github_repository_name" {
  default = "foggykitchen-hello-world"
}

variable "github_repository_url" {
  default = "https://github.com/mlinxfeld/foggykitchen-hello-world"
}

variable "oke_target_environment" {
  default = true
}

variable "availablity_domain_name" {
  default = ""
}

variable "kubernetes_version" {
  default = "v1.26.2"
  #default = "v1.25.4"
  #default = "v1.24.1"
  #default = "v1.23.4"
}

variable "node_pool_size" {
  default = 3
}

variable "oke_node_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "oke_node_os_version" {
  default = "8.7"
}

variable "oke_node_boot_volume_size_in_gbs" {
  default = 50
}

variable "flex_shape_memory" {
  default = 8
}

variable "flex_shape_ocpus" {
  default = 1
}

variable "cluster_name" {
  default = "FoggyKitchenOKECluster"
}

variable "pipeline_trigger" {
  default = true
}

variable "triggering_branch" {
  default = "master"
}

variable "deploy_stage_canary_namespace" {
  default = "canary-ns"
}

variable "deploy_stage_prod_namespace" {
  default = "prod-ns"
}

variable "percentage_canary_shift" {
  default = 25 
}

variable "canary_prod_release_count_of_approval" {
  default = 1 
}

variable "ingress_version" {
  default = "v1.1.2"
  #default = "v1.8.0"
}
