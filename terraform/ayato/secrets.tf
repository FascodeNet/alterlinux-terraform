resource "random_password" "ci_api_key" {
  length  = 48
  special = false
}

locals {
  ci_api_keys_json = jsonencode([{
    name          = "alterlinux-repo"
    key           = random_password.ci_api_key.result
    publish_repos = [for r in var.ayato_repos : r.name]
  }])

  secrets = {
    r2-access-key-id     = var.r2_access_key_id
    r2-secret-access-key = var.r2_secret_access_key
    cfkv-token           = var.cfkv_token
    ci-api-keys          = local.ci_api_keys_json
  }
}

resource "google_secret_manager_secret" "this" {
  for_each  = local.secrets
  secret_id = "ayato-${each.key}"

  replication {
    auto {}
  }

  depends_on = [google_project_service.this]
}

resource "google_secret_manager_secret_version" "this" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_member" "ayato" {
  for_each  = google_secret_manager_secret.this
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ayato.email}"
}
