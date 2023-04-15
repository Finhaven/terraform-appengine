# Module:  Multi Version
# Author:  Aaron Cimolini <aaron.cimolini@finhaven.com>
# Version: 0.1.0

# Required Variables ##########################################################

variable "versions" {
  description = "The specific data used to deploy each version."
}

variable "common_args" {
  description = "Map of common args to pass to the child module for all versions."
}

# Optional Variables ##########################################################
