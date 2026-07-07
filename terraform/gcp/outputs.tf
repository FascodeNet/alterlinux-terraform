output "project_id" {
  description = "The managed GCP project ID."
  value       = var.project_id
}

output "enabled_services" {
  description = "APIs enabled through this configuration."
  value       = sort([for s in google_project_service.this : s.service])
}
