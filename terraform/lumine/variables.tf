variable "cloudflare_api_token" {
  description = "Cloudflare API token with Account Cloudflare Pages:Edit, Zone DNS:Edit, and Zone:Read."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the Pages project."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID of the DNS zone serving the custom domain."
  type        = string
}

variable "pages_project_name" {
  description = "Cloudflare Pages project name (direct upload). Its <name>.pages.dev subdomain is globally unique; wrangler deploys to this name."
  type        = string
  default     = "alterlinux"
}

variable "lumine_domain" {
  description = "Custom domain for the lumine web UI."
  type        = string
  default     = "alter.hayao0819.com"
}

variable "production_branch" {
  description = "Production branch label the Pages project requires even for direct upload."
  type        = string
  default     = "main"
}
