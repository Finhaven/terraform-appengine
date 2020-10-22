variable "version" {
  description = "(Optional) Name of the App Engine version of the Service that will be deployed."
  type        = string
  default     = null

  validation {
    condition     = length(var.version) > 0 && length(var.version) < 63
    error_message = "The version name can't be null and the length cannot exceed 63 characters"
  }
}

variable "service" {
  description = "(Required; Default: default) Name of the App Engine Service"
  type        = string
  default     = "default"

  validation {
    condition     = length(var.service) > 0 && length(var.service) < 63
    error_message = "The Service name can't be null and the length cannot exceed 63 characters"
  }
}

variable "runtime" {
  description = "(Required; Default: python27) The runtime that will be used by App Engine. Supported runtimes are: python27, python37, python38, java8, java11, php55, php73, php74, ruby25, go111, go112, go113, go114, nodejs10, nodejs12.\n "
  type        = string
  default     = "python27"

  validation {
    condition     = contains(["python27", "python37", "python38", "java8", "java11", "php55", "php73", "php74", "ruby25", "go111", "go112", "go113", "go114", "nodejs10", "nodejs12"], var.runtime)
    error_message = "The specified runtime does not match any of the supported runtimes: \n - Python: python27, python37, python38 \n - Java: java8, java11 \n - PHP: php55, php73, php74 \n - Ruby: ruby25 \n - Go: go111, go112, go113, go114 \n - Node.js: nodejs10, nodejs12"
  }
}

variable "threadsafe" {
  description = "(Optional; Default True) Whether the application should use concurrent requests or not. Only appliable for python27 and java8 runtimes."
  type        = bool
  default     = true
}

variable "api_version" {
  desription = "(Optional; Default: 1)The version of the API in the given runtime environment that is used by your app. The field is deprecated for newer App Engine runtimes."
  type       = number
  default    = 1
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
  description = "(Optional; Default: F1) Instance class that is used to run this version. Valid values are AutomaticScaling: F1, F2, F4, F4_1G BasicScaling or ManualScaling: B1, B2, B4, B4_1G, B8 Defaults to F1 for AutomaticScaling and B2 for ManualScaling and BasicScaling. If no scaling is specified, AutomaticScaling is chosen."
  type        = string
  default     = "F1"

  validation {
    condition     = contains([B1, B2, B4, B4_1G, B8, F1, F2, F4, F4_1G], var.instance_class)
    error_message = "Instance class must be one of [B1, B2, B4, B4_1G, B8] for BasicScaling or ManualScaling and one of [F1, F2, F4, F4_1G] for AutomaticScaling"
  }
}

variable "inbound_services" {
  description = "(Optional) A list of the types of messages that this application is able to receive."
  type        = string
  default     = null

  validation {
    condition     = contains([INBOUND_SERVICE_MAIL, INBOUND_SERVICE_MAIL_BOUNCE, INBOUND_SERVICE_XMPP_ERROR, INBOUND_SERVICE_XMPP_MESSAGE, INBOUND_SERVICE_XMPP_SUBSCRIBE, INBOUND_SERVICE_XMPP_PRESENCE, INBOUND_SERVICE_CHANNEL_PRESENCE, INBOUND_SERVICE_WARMUP], var.inbound_services)
    error_message = "Inbound services must be one of the following [INBOUND_SERVICE_MAIL, INBOUND_SERVICE_MAIL_BOUNCE, INBOUND_SERVICE_XMPP_ERROR, INBOUND_SERVICE_XMPP_MESSAGE, INBOUND_SERVICE_XMPP_SUBSCRIBE, INBOUND_SERVICE_XMPP_PRESENCE, INBOUND_SERVICE_CHANNEL_PRESENCE, INBOUND_SERVICE_WARMUP]"
  }
}

variable "project" {
  description = "(Optional) The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "deployment" {
  description = "(Required) Code and application artifacts that make up this version."
  type = list(object({
    zip = list(object({
      source_url  = string,
      files_count = number
    })),
    files = list(object({
      name       = string,
      sha1_sum   = string,
      source_url = string
    }))
  }))
  default = null
}

variable "handlers" {
  description = "(Optional) An ordered list of URL-matching patterns that should be applied to incoming requests. The first matching URL handles the request and other request handlers are not attempted."
  type = list(object({
    url_regex                   = string,
    security_level              = string,
    login                       = string,
    auth_fail_action            = string,
    redirect_http_response_code = string,
    script = object({
      script_path = string
    })
    static_files = object({
      path                  = string,
      upload_path_regex     = string,
      http_headers          = map(),
      mime_type             = string,
      expiration            = string,
      require_matching_file = bool,
      application_readable  = bool
    })
  }))
  default = null
}

variable "libraries" {
  description = "(Optional) Configuration for third-party Python runtime libraries that are required by the application."
  type = list(object({
    name    = string,
    version = string
  }))
  default = null
}

variable "entrypoint" {
  description = "(Optional) The entrypoint for the application."
  type = object({
    shell = string
  })
  default = null
}

variable "automatic_scaling" {
  description = "(Optional) Automatic scaling is based on request rate, response latencies, and other application metrics."
  type = object({
    max_concurrent_requests = number,
    max_idle_instances      = any,
    max_pending_latency     = string,
    min_idle_instances      = any,
    min_pending_latency     = string,
    standard_scheduler_settings = object({
      target_cpu_utilization        = number,
      target_throughput_utilization = number,
      min_instances                 = number,
      max_instances                 = number
    })
  })
  default = {
    max_concurrent_requests = 10,
    max_idle_instances      = "automatic",
    max_pending_latency     = "30ms",
    min_idle_instances      = "automatic",
    min_pending_latency     = "0s",
    standard_scheduler_settings = {
      target_cpu_utilization        = 0.6,
      target_throughput_utilization = 0.6,
      min_instances                 = 0,
      max_instances                 = 1
    }
  }
}

variable "basic_scaling" {
  description = "(Optional) Basic scaling creates instances when your application receives requests. Each instance will be shut down when the application becomes idle. Basic scaling is ideal for work that is intermittent or driven by user activity."
  type = object({
    idle_timeout  = string,
    max_instances = number
  })
  default = null
}

variable "manual_scaling" {
  description = "(Optional) A service with manual scaling runs continuously, allowing you to perform complex initialization and rely on the state of its memory over time."
  type = object({
    instances = number
  })
  default = null
}