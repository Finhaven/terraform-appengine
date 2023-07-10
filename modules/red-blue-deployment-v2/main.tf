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

# Create the initial state files and set the placeholder app as the current
# version.
module "init" {
  source     = "./modules/init"
  depends_on = [google_storage_bucket_object.initial_code_zip]

  bucket_name    = var.bucket_name
  component_path = var.component_path
}

# Get Deployment State ########################################################

module "state" {
  source     = "./modules/state"
  depends_on = [module.init]

  bucket_name    = var.bucket_name
  component_path = var.component_path
  version_ids    = local.version_ids
  initial_hash   = local.initial_hash
}

locals {
  # Create a map of version_ids to hashes. If the hash is null set it to the
  # initial hash value.
  hashes = {
    for id, hash in module.state.hashes :
    # Trimspace is required since the data source appears to be appending
    # newlines to the file content.
    id => trimspace(coalesce(hash, local.initial_hash))
  }

  # The version that has been marked as current. If this deployment has not been
  # initialized set the current version to the first version ID. Trimspace is
  # required since the data source appears to be appending newlines to the file
  # content.
  current = trimspace(coalesce(
    module.state.current,
    local.version_ids[0]
  ))

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
