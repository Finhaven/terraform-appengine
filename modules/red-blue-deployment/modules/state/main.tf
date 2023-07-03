# Module: GAE Red/Blue Deployment State
# Author: Aaron Cimolini
# <aaron.cimolini@finhaven.com> Version: 0.1.0

# Required Variables ##########################################################

variable "bucket_name" {
  description = "Name of the bucket where the deployment artifacts and state files are kept."
  type        = string
}

variable "component_path" {
  description = "Path to where the component archive files are stored with their current and previous hashes."
  type        = string
}

# Data Sources ################################################################

locals {
  version_ids = [
    "blue",
    "red",
  ]
}

data "google_storage_bucket_object_content" "hashes" {
  for_each = toset(local.version_ids)

  name   = "${var.component_path}/${each.value}"
  bucket = var.bucket_name
}

data "google_storage_bucket_object_content" "current" {
  name   = "${var.component_path}/current"
  bucket = var.bucket_name
}

# Locals ######################################################################

locals {
  # Create a map of version_ids to hashes, skipping over any empty hashes.
  hashes = {
    for id, obj in data.google_storage_bucket_object_content.hashes :
    id => obj.content
  }

  # The version that has been marked as current.
  current = data.google_storage_bucket_object_content.current.content

  # Build url base to use in zip.source_urls in the GAE service version module.
  url_base = join("/", [
    "https://storage.googleapis.com",
    var.bucket_name,
    var.component_path,
  ])

  # Build the split traffic allocations and set all traffic to go to the current
  # version.
  allocations = {
    for id, hash in local.hashes :
    id => 1
    if local.current == id
  }

  # Build the source urls.
  source_urls = {
    for id, hash in local.hashes :
    id => try("${local.url_base}/${hash}.zip", "")
  }

  # Build the version specific settings for the GAE service versions.
  versions = {
    for id, hash in local.hashes :
    id => {
      service_version = id
      zip = {
        source_url = local.source_urls[id]
      }
    }
  }
}

# Outputs #####################################################################

output "data" {
  value = {
    hashes   = local.hashes
    current  = local.current
    url_base = local.url_base
  }
}

output "split_traffic" {
  value = {
    allocations = local.allocations
  }
}

output "versions" {
  value = local.versions
}
