resource "google_cloud_run_domain_mapping" "ayato" {
  for_each = toset(var.ayato_domains)

  name     = each.value
  location = var.region

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.ayato.name
  }
}
