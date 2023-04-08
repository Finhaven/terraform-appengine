# Collect the different regions available within GCP.
data "google_compute_regions" "available" {
  project = var.project_id
}

resource "google_app_engine_application" "appengine_app" {
  # Ensure valid location has been passed.
  location_id = contains(
    data.google_compute_regions.available.names,
    var.location_id
  ) == true ? var.location_id : "This is not one of the available locations in GCP."

  project        = var.project_id
  auth_domain    = var.auth_domain
  database_type  = var.database_type
  serving_status = var.serving_status

  # Conditional dynamic blocks using the splat operator.
  # https://developer.hashicorp.com/terraform/language/expressions/splat#single-values-as-lists

  dynamic "feature_settings" {
    for_each = var.feature_settings[*]

    content {
      split_health_checks = feature_settings.value.split_health_checks
    }
  }

  dynamic "iap" {
    for_each = var.iap[*]

    content {
      oauth2_client_id     = iap.value.oauth2_client_id
      oauth2_client_secret = iap.value.oauth2_client_secret
    }
  }
}
