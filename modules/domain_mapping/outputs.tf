output "id" {
  description = "An identifier for the resource with format apps/{{project}}/domainMappings/{{domain_name}}"
  value       = google_app_engine_domain_mapping.domain_mapping.id
}

output "name" {
  description = "Full path to the DomainMapping resource in the API. Example: apps/myapp/domainMapping/example.com"
  value       = google_app_engine_domain_mapping.domain_mapping.name
}

output "resource_records" {
  description = "The resource records required to configure this domain mapping. These records must be added to the domain's DNS configuration in order to serve the application via this domain mapping."
  value       = google_app_engine_domain_mapping.domain_mapping.resource_records
}
