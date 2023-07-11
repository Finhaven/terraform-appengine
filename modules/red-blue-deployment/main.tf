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

variable "initial_code_zip_path" {
  description = "Path to a zip file to upload to the bucket and set as the initial service version."
  type        = string
}

# Settings ####################################################################

locals {
  # Hash to use when first initializing the deployment. May be any string. The
  # value specified will be appended with `.zip` and the build script will look
  # for that zip file in the bucket at the `component_path`.
  initial_hash = "initial"
  version_ids = [
    "blue",
    "red",
  ]
  initial_filename          = "${local.initial_hash}.zip"
  version_switcher_filename = "version-switcher.sh"
  scripts_dir               = "scripts"

  component_url = "gs://${var.bucket_name}/${var.component_path}"
}

# Initialize Deployment State #################################################

# Copy the default placeholder app archive to the bucket.
resource "google_storage_bucket_object" "initial_code_zip" {
  name = join("/", [
    var.component_path,
    local.initial_filename,
  ])
  source = var.initial_code_zip_path
  bucket = var.bucket_name
}

# Copy the version-switcher.sh script to the bucket so it may be used by the
# Cloud Build trigger.
resource "google_storage_bucket_object" "script" {
  name = join("/", [
    var.component_path,
    local.version_switcher_filename,
  ])
  source = join("/", [
    path.module,
    local.scripts_dir,
    local.version_switcher_filename,
  ])

  bucket = var.bucket_name
}

# Get Deployment State ########################################################

module "state" {
  source = "Invicton-Labs/shell-data/external"

  environment = {
    COMPONENT_URL = local.component_url
  }
  command_unix = file(join("/", [
    path.module,
    local.scripts_dir,
    "get-deployment-state.sh"
  ]))
}

locals {
  state = jsondecode(module.state.stdout)

  # Create a map of version_ids to hashes.
  hashes = {
    for id in local.version_ids :
    id => local.state[id]
  }

  # Build url base to use in zip.source_urls in the GAE service version module.
  url_base = join("/", [
    "https://storage.googleapis.com",
    var.bucket_name,
    var.component_path,
  ])

  allocations = {
    (local.state.current) = 1
  }

  # Build the version specific settings for the GAE service versions.
  versions = {
    for id, hash in local.hashes :
    id => {
      service_version = id
      zip = {
        source_url = "${local.url_base}/${hash}.zip"
      }
    }
  }
}

# Outputs #####################################################################

output "data" {
  value = {
    hashes   = local.hashes
    current  = local.state.current
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

output "debug" {
  value = local.state
}
