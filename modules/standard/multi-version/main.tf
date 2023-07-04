# Module:  Multi Version
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

locals {
  # Passing untyped objects using Terragrunt results in JSON strings in the
  # variables. Using jsondecode to rehydrate the objects. Try function ensures
  # that we can use this module in Terragrunt and in other Terraform modules.
  # Terraform handles untyped variables correctly.
  versions    = try(jsondecode(var.versions), var.versions)
  common_args = try(jsondecode(var.common_args), var.common_args)
}

module "versions" {
  for_each = local.versions
  source   = "../automatic_scaling"

  # Version specific args.
  service_version = each.value.service_version
  zip             = each.value.zip

  # Common version args.
  project_id                = try(local.common_args.project_id, null)
  service_account           = try(local.common_args.service_account, null)
  service                   = try(local.common_args.service, null)
  runtime                   = try(local.common_args.runtime, null)
  threadsafe                = try(local.common_args.threadsafe, null)
  env_variables             = try(local.common_args.env_variables, null)
  noop_on_destroy           = try(local.common_args.noop_on_destroy, null)
  delete_service_on_destroy = try(local.common_args.delete_service_on_destroy, null)
  instance_class            = try(local.common_args.instance_class, null)
  inbound_services          = try(local.common_args.inbound_services, null)
  handlers                  = try(local.common_args.handlers, null)
  libraries                 = try(local.common_args.libraries, null)
  entrypoint                = try(local.common_args.entrypoint, null)
  automatic_scaling         = try(local.common_args.automatic_scaling, null)
  vpc_access_connector      = try(local.common_args.vpc_access_connector, null)
}
