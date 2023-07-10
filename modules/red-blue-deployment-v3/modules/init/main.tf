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

# Initialize Deployment State #################################################

locals {
  init_path     = "${path.module}/init.sh"
  component_url = "gs://${var.bucket_name}/${var.component_path}"
}

resource "terraform_data" "init" {
  # Because there is no `triggers_replace` attribute this script runs only once
  # during the first apply.
  provisioner "local-exec" {
    command = "COMPONENT_URL=${local.component_url} ${local.init_path}"
  }
}
