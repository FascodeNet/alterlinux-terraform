output "pages_project_name" {
  description = "Pages project name; pass to `wrangler pages deploy --project-name`."
  value       = cloudflare_pages_project.lumine.name
}

output "pages_subdomain" {
  description = "Default <name>.pages.dev host for the project."
  value       = cloudflare_pages_project.lumine.subdomain
}

output "lumine_url" {
  description = "Public URL of the lumine web UI."
  value       = "https://${var.lumine_domain}"
}
