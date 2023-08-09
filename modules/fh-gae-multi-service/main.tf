# Module:  GAE App Multi-Service
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

module "services" {
  source   = "../fh-gae-app-service"
  for_each = var.services

  # Common to all services.
  project_id            = var.project_id
  artifact_bucket_name  = var.artifact_bucket_name
  vpc_access_connector  = var.vpc_access_connector
  initial_code_zip_path = var.initial_code_zip_path

  # Service specific settings.
  service_name              = each.key
  component_path            = each.value.component_path
  runtime                   = each.value.runtime
  service_account           = each.value.service_account
  entrypoint                = each.value.entrypoint
  env_variables             = each.value.env_variables
  noop_on_destroy           = each.value.noop_on_destroy
  delete_service_on_destroy = each.value.delete_service_on_destroy
}
