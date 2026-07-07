locals {
  services = [
    "run.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

resource "google_project_service" "this" {
  for_each = toset(local.services)

  service            = each.value
  disable_on_destroy = false
}
