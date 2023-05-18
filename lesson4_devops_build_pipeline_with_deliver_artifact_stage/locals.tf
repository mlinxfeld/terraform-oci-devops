locals {
  ssh_port_number        = "22"
  tcp_protocol_number    = "6"
  all_protocols          = "all"
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_objectstorage_namespace.objectstorage_namespace, "namespace")
  secret_bundle_content  = base64decode(data.oci_secrets_secretbundle.FoggyKitchenSecretBundle.secret_bundle_content[0].content) 
  ocir_user_name         = jsondecode(local.secret_bundle_content).username 
  ocir_user_password     = jsondecode(local.secret_bundle_content).password 
}
