output "ayato_url" {
  description = "Public URL of the ayato Cloud Run service."
  value       = google_cloud_run_v2_service.ayato.uri
}

output "r2_bucket" {
  description = "R2 bucket name for package blobs."
  value       = var.r2_bucket_name
}

output "domain_mapping_dns" {
  description = "DNS records to add in Cloudflare (DNS only / grey cloud) for each mapped domain."
  value = {
    for domain, m in google_cloud_run_domain_mapping.ayato :
    domain => m.status[0].resource_records
  }
}

output "ci_api_key" {
  description = "API key for alterlinux-repo CI (set as the AYATO_TOKEN secret)."
  value       = random_password.ci_api_key.result
  sensitive   = true
}
