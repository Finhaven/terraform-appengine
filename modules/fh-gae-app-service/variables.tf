# Module:  Finhaven GAE App Service
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

variable "service_name" {
  description = "(Required) The name of the service these settings apply to."
  type        = string
}

variable "component_path" {
  description = "Path to where the component archive files are stored with their current and previous hashes."
  type        = string
}

variable "initial_code_zip_path" {
  description = "Path to a zip file to upload to the bucket and set as the initial service version."
  type        = string
}

variable "runtime" {
  description = "The GAE runtime to use for the service."
  type        = string
}

# Optional Variables ##########################################################

variable "service_account" {
  description = "The identity that the deployed version will run as. Admin API will use the App Engine Appspot service account as default if this field is neither provided in app.yaml file nor through CLI flag."
  type        = string
  default     = null
}

variable "entrypoint" {
  description = "(Optional) The entrypoint for the application."
  type = object({
    shell = string
  })
  default = null
}

variable "vpc_access_connector" {
  description = "(Optional) Enables VPC connectivity for standard apps."
  type = object({
    name = string
  })
  default = null
}

variable "env_variables" {
  description = "(Optional) Environment variables to be passed to the App Engine service"
  type        = map(any)
  default     = {}
}

variable "noop_on_destroy" {
  description = "(Optional; Default: True)If set to true, the application version will not be deleted upon running Terraform destroy."
  type        = bool
  default     = true
}

variable "delete_service_on_destroy" {
  description = "(Optional; Default: False)If set to true, the service will be deleted if it is the last version."
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "(Optional; Default: F1) Instance class that is used to run this version."
  type        = string
  default     = "F1"
}
