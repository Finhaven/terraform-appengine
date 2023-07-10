# Module: GAE Red/Blue Deployment State
# Author: Aaron Cimolini
# <aaron.cimolini@finhaven.com> Version: 0.2.0

# Required Variables ##########################################################

variable "bucket_name" {
  description = "Name of the bucket where the deployment artifacts and state files are kept."
  type        = string
}

variable "component_path" {
  description = "Path to where the component archive files are stored with their current and previous hashes."
  type        = string
}

variable "version_ids" {
  type = list(string)
}

variable "initial_hash" {
  type = string
}

# Data Sources ################################################################

data "google_storage_bucket_object_content" "hashes" {
  for_each = toset(var.version_ids)

  name   = "${var.component_path}/${each.value}"
  bucket = var.bucket_name
}

data "google_storage_bucket_object_content" "current" {
  name   = "${var.component_path}/current"
  bucket = var.bucket_name
}

# Outputs #####################################################################

output "hashes" {
  value = {
    for id, obj in data.google_storage_bucket_object_content.hashes :
    id => obj.content
  }
}

output "current" {
  value = data.google_storage_bucket_object_content.current.content
}
