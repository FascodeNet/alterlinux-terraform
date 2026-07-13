data "docker_registry_image" "ayato" {
  name = "${var.ayato_digest_repo}:${var.ayato_image_tag}"
}

resource "google_service_account" "ayato" {
  account_id   = "ayato-run"
  display_name = "ayato Cloud Run"
}

resource "google_cloud_run_v2_service" "ayato" {
  name                = "ayato"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.ayato.email

    containers {
      image   = "${var.ayato_image_repo}@${data.docker_registry_image.ayato.sha256_digest}"
      command = ["ayato"]

      resources {
        startup_cpu_boost = true
        # explicit: a resources block flips cpu_idle's default to false
        cpu_idle = true
      }

      startup_probe {
        http_get {
          path = "/health"
        }
      }

      env {
        name  = "AYATO_STORE_DB_TYPE"
        value = "cfkv"
      }
      env {
        name  = "AYATO_STORE_STORAGE_TYPE"
        value = "s3"
      }
      env {
        name  = "AYATO_STORE_CFKV_ACCOUNT_ID"
        value = var.cloudflare_account_id
      }
      env {
        name  = "AYATO_STORE_CFKV_NAMESPACE"
        value = var.cfkv_namespace_id
      }
      env {
        name  = "AYATO_STORE_AWSS3_REGION"
        value = "auto"
      }
      env {
        name  = "AYATO_STORE_AWSS3_BUCKET"
        value = var.r2_bucket_name
      }
      env {
        name  = "AYATO_STORE_AWSS3_ENDPOINT"
        value = local.r2_endpoint
      }
      env {
        name  = "AYATO_STORE_AWSS3_USE_PATH_STYLE"
        value = "true"
      }
      env {
        name  = "AYATO_REPOS"
        value = jsonencode(var.ayato_repos)
      }

      dynamic "env" {
        for_each = var.auth_public_origin != "" ? [1] : []
        content {
          name  = "AYATO_AUTH_PUBLIC_ORIGIN"
          value = var.auth_public_origin
        }
      }

      env {
        name = "AYATO_STORE_CFKV_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.this["cfkv-token"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "AYATO_STORE_AWSS3_ACCESS_KEY_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.this["r2-access-key-id"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "AYATO_STORE_AWSS3_SECRET_ACCESS_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.this["r2-secret-access-key"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "AYATO_AUTH_CI_API_KEYS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.this["ci-api-keys"].secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.this,
    google_secret_manager_secret_iam_member.ayato,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = google_cloud_run_v2_service.ayato.project
  location = google_cloud_run_v2_service.ayato.location
  name     = google_cloud_run_v2_service.ayato.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
