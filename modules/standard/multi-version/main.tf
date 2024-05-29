# Module:  Multi Version
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

locals {
  # Passing untyped objects using Terragrunt results in JSON strings in the
  # variables. Using jsondecode to rehydrate the objects. Try function ensures
  # that we can use this module in Terragrunt and in other Terraform modules.
  # Terraform handles untyped variables correctly.
  versions = try(jsondecode(var.versions), var.versions)
}

module "versions" {
  for_each = local.versions
  source   = "../automatic_scaling"

  # Version specific args.
  service_version = each.value.service_version
  zip             = each.value.zip

  # Common version args.
  project_id                = var.project_id
  service_account           = var.service_account
  service                   = var.service
  runtime                   = var.runtime
  env_variables             = var.env_variables
  noop_on_destroy           = var.noop_on_destroy
  delete_service_on_destroy = var.delete_service_on_destroy
  entrypoint                = var.entrypoint
  vpc_access_connector      = var.vpc_access_connector
  instance_class            = var.instance_class
}
