variable "service_version" {
  description = "(Optional) Name of the App Engine version of the Service that will be deployed."
  type        = string
  default     = null

  validation {
    condition     = length(var.service_version) > 0 && length(var.service_version) < 63
    error_message = "The version name can't be null and the length cannot exceed 63 characters."
  }
}

variable "service" {
  description = "(Required; Default: default) Name of the App Engine Service"
  type        = string
  default     = "default"

  validation {
    condition     = length(var.service) > 0 && length(var.service) < 63
    error_message = "The Service name can't be null and the length cannot exceed 63 characters."
  }
}

variable "runtime" {
  description = "(Required; Default: python27) The runtime that will be used by App Engine. Supported runtimes are: python27, python37, python38, java8, java11, php55, php73, php74, ruby25, go111, go112, go113, go114, nodejs10, nodejs12."
  type        = string
  default     = "python27"

  validation {
    condition     = contains(["python27", "python37", "python38", "java8", "java11", "php55", "php73", "php74", "ruby25", "go111", "go112", "go113", "go114", "nodejs10", "nodejs12"], var.runtime)
    error_message = "The specified runtime does not match any of the supported runtimes: \n - Python: python27, python37, python38 \n - Java: java8, java11 \n - PHP: php55, php73, php74 \n - Ruby: ruby25 \n - Go: go111, go112, go113, go114 \n - Node.js: nodejs10, nodejs12."
  }
}

variable "threadsafe" {
  description = "(Optional; Default True) Whether the application should use concurrent requests or not. Only appliable for python27 and java8 runtimes."
  type        = bool
  default     = true
}

variable "api_version" {
  description = "(Optional; Default: 1)The version of the API in the given runtime environment that is used by your app. The field is deprecated for newer App Engine runtimes."
  type        = number
  default     = 1
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
    condition     = contains(["B1", "B2", "B4", "B4_1G", "B8", "F1", "F2", "F4", "F4_1G"], var.instance_class)
    error_message = "Instance class must be one of [B1, B2, B4, B4_1G, B8] for BasicScaling or ManualScaling and one of [F1, F2, F4, F4_1G] for AutomaticScaling."
  }
}

variable "inbound_services" {
  description = "(Optional) A list of the types of messages that this application is able to receive."
  type        = string
  default     = null

  validation {
    condition     = contains(["INBOUND_SERVICE_MAIL", "INBOUND_SERVICE_MAIL_BOUNCE", "INBOUND_SERVICE_XMPP_ERROR", "INBOUND_SERVICE_XMPP_MESSAGE", "INBOUND_SERVICE_XMPP_SUBSCRIBE", "INBOUND_SERVICE_XMPP_PRESENCE", "INBOUND_SERVICE_CHANNEL_PRESENCE", "INBOUND_SERVICE_WARMUP"], var.inbound_services)
    error_message = "Inbound services must be one of the following [INBOUND_SERVICE_MAIL, INBOUND_SERVICE_MAIL_BOUNCE, INBOUND_SERVICE_XMPP_ERROR, INBOUND_SERVICE_XMPP_MESSAGE, INBOUND_SERVICE_XMPP_SUBSCRIBE, INBOUND_SERVICE_XMPP_PRESENCE, INBOUND_SERVICE_CHANNEL_PRESENCE, INBOUND_SERVICE_WARMUP]."
  }
}

variable "project" {

}

variable "zip" {
  description = "(Optional) Zip File Structure."
  type = object({
    source_url  = string,
    files_count = number
  })
  default = null
}

variable "files" {
  description = "(Optional) Manifest of the files stored in Google Cloud Storage that are included as part of this version."

  type = object({
    name       = string,
    sha1_sum   = string,
    source_url = string
  })
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
      http_headers          = map(string),
      mime_type             = string,
      expiration            = string,
      require_matching_file = bool,
      application_readable  = bool
    })
  }))

  validation {
    condition     = contains([SECURE_DEFAULT, SECURE_NEVER, SECURE_OPTIONAL, SECURE_ALWAYS], var.handlers.security_level)
    error_message = "Security level field value must be one of [SECURE_DEFAULT, SECURE_NEVER, SECURE_OPTIONAL, SECURE_ALWAYS]."
  }
  validation {
    condition     = contains([LOGIN_OPTIONAL, LOGIN_ADMIN, LOGIN_REQUIRED], var.handlers.login)
    error_message = "Login field value must be one of [LOGIN_OPTIONAL, LOGIN_ADMIN, LOGIN_REQUIRED]."
  }
  validation {
    condition     = contains([AUTH_FAIL_ACTION_REDIRECT, AUTH_FAIL_ACTION_UNAUTHORIZED], var.handlers.auth_fail_action)
    error_message = "Auth fail action field value must be one of [AUTH_FAIL_ACTION_REDIRECT,AUTH_FAIL_ACTION_UNAUTHORIZED]."
  }
  validation {
    condition     = contains([REDIRECT_HTTP_RESPONSE_CODE_301, REDIRECT_HTTP_RESPONSE_CODE_302, REDIRECT_HTTP_RESPONSE_CODE_303, REDIRECT_HTTP_RESPONSE_CODE_307], var.handlers.redirect_http_response_code)
    error_message = "Redirect HTTP response code field value must be one of [REDIRECT_HTTP_RESPONSE_CODE_301, REDIRECT_HTTP_RESPONSE_CODE_302, REDIRECT_HTTP_RESPONSE_CODE_303, REDIRECT_HTTP_RESPONSE_CODE_307]."
  }
  default = [{
    url_regex                   = null,
    security_level              = "SECURE_DEFAULT",
    login                       = "LOGIN_OPTIONAL",
    auth_fail_action            = "AUTH_FAIL_ACTION_REDIRECT",
    redirect_http_response_code = "REDIRECT_HTTP_RESPONSE_CODE_301",
    script = {
      script_path = null
    }
    static_files = {
      path                  = null,
      upload_path_regex     = null,
      http_headers          = null,
      mime_type             = null,
      expiration            = "600s",
      require_matching_file = false,
      application_readable  = false
    }
  }]

}

variable "libraries" {
  description = "(Optional) Configuration for third-party Python runtime libraries that are required by the application."
  type = list(object({
    name    = string,
    version = string
  }))
  default = [{
    name    = null,
    version = "latest"
  }]
}

variable "entrypoint" {
  description = "(Optional) The entrypoint for the application."
  type = object({
    shell = string
  })
  default = {
    shell = null
  }
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

  validation {
    condition     = var.automatic_scaling.max_concurrent_requests >= 10 && var.automatic_scaling.max_concurrent_requests <= 80
    error_message = "The value of max_concurrent_requests must fall within range [10, 80]"
  }
  validation {
    condition     = var.automatic_scaling.max_idle_instances == "automatic" || (var.automatic_scaling.max_idle_instances >= 1 && var.automatic_scaling.max_idle_instances <= 1000)
    error_message = "The value of max_idle_instances needs to be `automatic` or fall within range [1, 1000]"
  }
  validation {
    condition     = var.automatic_scaling.min_idle_instances == "automatic" || (var.automatic_scaling.min_idle_instances >= 1 && var.automatic_scaling.min_idle_instances <= 1000)
    error_message = "The value of min_idle_instances needs to be `automatic` or fall within range [1, 1000]"
  }
  validation {
    condition     = var.automatic_scaling.standard_scheduler_settings.target_cpu_utilization >= 0.5 && var.automatic_scaling.standard_scheduler_settings.target_cpu_utilization <= 0.95
    error_message = "The target_cpu_utilization value must fall within range [0.5, 0.95]"
  }
  validation {
    condition     = var.automatic_scaling.standard_scheduler_settings.target_throughput_utilization >= 0.5 && var.automatic_scaling.standard_scheduler_settings.target_throughput_utilization <= 0.95
    error_message = "The target_throughput_utilization value must fall within range [0.5, 0.95]"
  }
  validation {
    condition     = var.automatic_scaling.standard_scheduler_settings.min_instances >= 0 && var.automatic_scaling.standard_scheduler_settings.min_instances <= 1000
    error_message = "The min_instances value must fall within range [0,1000]"
  }
  validation {
    condition     = var.automatic_scaling.standard_scheduler_settings.max_instances >= 0 && var.automatic_scaling.standard_scheduler_settings.max_instances <= 2147483647
    error_message = "The max_instances value must fall within range [0,2147483647]"
  }
}

variable "basic_scaling" {
  description = "(Optional) Basic scaling creates instances when your application receives requests. Each instance will be shut down when the application becomes idle. Basic scaling is ideal for work that is intermittent or driven by user activity."
  type = object({
    idle_timeout  = string,
    max_instances = number
  })
  default = {
    idle_timeout  = "300s"
    max_instances = 1
  }

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 200
    error_message = "The number of max instances needs to be in the range [1,200]."
  }
}

variable "manual_scaling" {
  description = "(Optional) A service with manual scaling runs continuously, allowing you to perform complex initialization and rely on the state of its memory over time."
  type = object({
    instances = number
  })
  default = {
    instances = 1
  }

  validation {
    condition     = var.manual_scaling.instances > 0
    error_message = "You must allocate at least 1 instance."
  }
}

variable "vpc_access_connector" {
  description = "(Optional) Enables VPC connectivity for standard apps."
  type = object({
    name = string
  })
  default = null

  validation {
    condition     = length(regexall("^/\\bprojects\\b/[[:word:]-]+/\\blocations\\b/[[:word:]-]+/\\bconnectors\\b/[[:word:]-]+$", var.vpc_access_connector.name)) > 0
    error_message = "Format of VPC access connector must use the following format `projects/[$PROJECT_NAME]/locations/[$CONNECTOR_LOCATION]/connectors/[$CONNECTOR_NAME]`."
  }
}