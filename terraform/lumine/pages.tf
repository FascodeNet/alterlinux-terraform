resource "cloudflare_pages_project" "lumine" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = var.production_branch
}

resource "cloudflare_pages_domain" "lumine" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.lumine.name
  name         = var.lumine_domain
}

# cloudflare_pages_domain does not create the DNS record itself; the custom domain
# is a proxied CNAME to the project's <name>.pages.dev host.
resource "cloudflare_dns_record" "lumine" {
  zone_id = var.cloudflare_zone_id
  name    = var.lumine_domain
  type    = "CNAME"
  content = cloudflare_pages_project.lumine.subdomain
  proxied = true
  ttl     = 1
}
