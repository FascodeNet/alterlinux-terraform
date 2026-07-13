# One-shot data-layout migration job. Same image, service account, store env and
# secrets as the service, but run as a Job (full CPU, no request timeout, retries)
# instead of on the serving instance. Args default to --status; override the phase
# at run time, e.g.
#   gcloud run jobs execute ayato-migrate --region <region> \
#     --args="migrate,--phase,expand" --wait
resource "google_cloud_run_v2_job" "ayato_migrate" {
  name                = "ayato-migrate"
  location            = var.region
  deletion_protection = false

  template {
    task_count = 1

    template {
      service_account = google_service_account.ayato.email
      max_retries     = 3
      timeout         = "3600s"

      containers {
        image   = "${var.ayato_image_repo}@${data.docker_registry_image.ayato.sha256_digest}"
        command = ["ayato"]
        args    = ["migrate", "--status"]

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
      }
    }
  }

  depends_on = [
    google_project_service.this,
    google_secret_manager_secret_iam_member.ayato,
  ]
}
