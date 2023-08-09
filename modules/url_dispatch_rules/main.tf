resource "google_app_engine_application_url_dispatch_rules" "rules" {
  project = var.project_id

  dynamic "dispatch_rules" {
    for_each = toset(var.dispatch_rules)
    iterator = rule

    content {
      # (Optional) Domain name to match against.
      domain = try(rule.value.domain, null)
      # (Required; Default: /*) Pathname within the host. Must start with a `/`. A
      # single `*` can be included at the end of the path.
      path = rule.value.path
      # (Required) App Engine service to which the dispatch rules should be
      # applied.
      service = rule.value.service
    }
  }
}
