# Module:  GAE App Multi-Service
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

# Required Variables ##########################################################

variable "project_id" {
  description = "ID of project in which to create the split traffic."
  type        = string
}

variable "artifact_bucket_name" {
  description = "Name of the bucket where the deployment artifacts and state files are kept."
  type        = string
}

variable "initial_code_zip_path" {
  description = "Path to a zip file to upload to the buckets and set as the initial service version for all services.."
  type        = string
}

variable "services" {
  description = "Map of the services to create."
  type = map(object({
    # Path to where the component archive files are stored with their current
    # and previous hashes.
    component_path = string

    # The GAE runtime to use for the service.
    runtime = string

    # The identity that the deployed version will run as. Admin API will use the
    # App Engine Appspot service account as default if this field is neither
    # provided in app.yaml file nor through CLI flag.
    service_account = optional(string, null)

    # The entrypoint for the application.
    entrypoint = optional(object({
      shell = string
    }), null)

    # Enables VPC connectivity for standard apps.
    vpc_access_connector = optional(object({
      name = string
    }), null)

    # Environment variables to be passed to the App Engine service.
    env_variables = optional(map(any), {})

    # If set to true, the application version will not be deleted upon running
    # Terraform destroy.
    noop_on_destroy = optional(bool, true)

    # If set to true, the service will be deleted if it is the last version.
    delete_service_on_destroy = optional(bool, false)
  }))
}

# Optional Variables ##########################################################

variable "vpc_access_connector" {
  description = "VPC Access Connector for all services to use."
  type = object({
    name = string
  })
  default = null
}
