# Module:  Finhaven GAE App Service
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

# Required Variables ##########################################################

variable "project_id" {
  description = "ID of project in which to create the split traffic."
}

variable "service_name" {
  description = "(Required) The name of the service these settings apply to."
  type        = string
}

variable "common_args" {
  description = "Map of common args to pass to the child module for all versions."
}

variable "artifact_bucket_name" {
  description = "Name of the bucket where the deployment artifacts and state files are kept."
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

# Optional Variables ##########################################################
