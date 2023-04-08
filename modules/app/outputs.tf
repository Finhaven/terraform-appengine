locals {
  app = google_app_engine_application.appengine_app
}

output "id" {
  description = "An identifier for the resource with format {{project}}."
  value       = local.app.id
}

output "name" {
  description = "Unique name of the app, usually apps/{PROJECT_ID}."
  value       = local.app.name
}

output "app_id" {
  description = "Identifier of the app, usually {PROJECT_ID}."
  value       = local.app.app_id
}

output "url_dispatch_rule" {
  description = "A list of dispatch rule blocks. Each block has a domain, path, and service field."
  value       = local.app.url_dispatch_rule
}

output "code_bucket" {
  description = "The GCS bucket code is being stored in for this app."
  value       = local.app.code_bucket
}

output "default_hostname" {
  description = "The default hostname for this app."
  value       = local.app.default_hostname
}

output "default_bucket" {
  description = "The GCS bucket content is being stored in for this app."
  value       = local.app.default_bucket
}

output "gcr_domain" {
  description = "The GCR domain used for storing managed Docker images for this app."
  value       = local.app.gcr_domain
}

output "iap" {
  description = "Settings for enabling Cloud Identity Aware Proxy."
  value       = local.app.iap
}

output "iap_enabled" {
  description = "(Optional) Whether the serving infrastructure will authenticate and authorize all incoming requests. (default is false)"
  value       = length(local.app.iap) != 0
}

output "iap_oauth2_client_secret_sha256" {
  description = "Hex-encoded SHA-256 hash of the client secret."
  value       = length(local.app.iap) != 0 ? local.app.iap[1] : {}
}
