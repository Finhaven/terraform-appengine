resource "google_app_engine_service_split_traffic" "split_traffic" {
  project         = var.project_id
  service         = var.service
  migrate_traffic = var.migrate_traffic

  split {
    shard_by    = var.shard_by
    allocations = var.allocations
  }
}
