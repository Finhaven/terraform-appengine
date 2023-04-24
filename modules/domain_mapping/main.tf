resource "google_app_engine_domain_mapping" "domain_mapping" {
  domain_name       = var.domain_name
  project           = var.project_id
  override_strategy = var.override_strategy

  dynamic "ssl_settings" {
    for_each = var.ssl_settings[*]

    content {
      certificate_id      = ssl_settings.value.certificate_id
      ssl_management_type = ssl_settings.value.ssl_management_type
    }
  }
}
