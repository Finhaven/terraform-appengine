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

variable "initial_code_zip_path" {
  description = "Path to a zip file to upload to the bucket and set as the initial service version."
  type        = string
}

# Initialize Deployment State #################################################

locals {
  initial_filename          = "initial.zip"
  version_switcher_filename = "version-switcher.sh"
  scripts_dir               = "scripts"
}

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
}

# Outputs #####################################################################

output "data" {
  value = module.state.data
}

output "split_traffic" {
  value = module.state.split_traffic
}

output "versions" {
  value = module.state.versions
}
