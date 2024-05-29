# Module:  Multi Version
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

# Required Variables ##########################################################

variable "project_id" {
  description = "(Required) The project ID to create the application under."
  type        = string
}

variable "versions" {
  description = "The specific data used to deploy each version."
}

variable "runtime" {
  description = "(Required) The runtime that will be used by App Engine."
  type        = string
}

# Optional Variables ##########################################################

variable "service" {
  description = "Name of the App Engine Service"
  type        = string
  default     = "default"
}

variable "service_account" {
  description = "The identity that the deployed version will run as. Admin API will use the App Engine Appspot service account as default if this field is neither provided in app.yaml file nor through CLI flag."
  type        = string
  default     = null
}

variable "env_variables" {
  description = "Environment variables to be passed to the App Engine service"
  type        = map(any)
  default     = {}
}

variable "noop_on_destroy" {
  description = "If set to true, the application version will not be deleted upon running Terraform destroy."
  type        = bool
  default     = true
}

variable "delete_service_on_destroy" {
  description = "If set to true, the service will be deleted if it is the last version."
  type        = bool
  default     = false
}

variable "entrypoint" {
  description = "The entrypoint for the application."
  type = object({
    shell = string
  })
  default = null
}

variable "vpc_access_connector" {
  description = "Enables VPC connectivity for standard apps."
  type = object({
    name = string
  })
  default = null
}

variable "instance_class" {
  description = "(Optional; Default: F1) Instance class that is used to run this version."
  type        = string
  default     = "F1"
}
