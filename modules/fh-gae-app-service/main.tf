# Module:  Finhaven GAE App Service
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

module "deployment_state" {
  source = "../red-blue-deployment"

  bucket_name           = var.artifact_bucket_name
  component_path        = var.component_path
  initial_code_zip_path = var.initial_code_zip_path
}

module "app_versions" {
  source = "../standard/multi-version"

  versions                  = module.deployment_state.versions
  project_id                = var.project_id
  service                   = var.service_name
  service_account           = var.service_account
  runtime                   = var.runtime
  env_variables             = var.env_variables
  noop_on_destroy           = var.noop_on_destroy
  delete_service_on_destroy = var.delete_service_on_destroy
  entrypoint                = var.entrypoint
  vpc_access_connector      = var.vpc_access_connector
}

module "split_traffic" {
  source     = "../split_traffic"
  depends_on = [module.app_versions]

  project_id   = var.project_id
  service_name = var.service_name
  allocations  = module.deployment_state.split_traffic.allocations

  # Leave these settings alone, unless you want to do some testing and
  # debugging. Deploys would fail if I used any other values. I never figured
  # out why different settings would not work.
  # - Aaron Cimolini <aaron.cimolini@finhaven.com>
  shard_by        = "IP"
  migrate_traffic = false
}
