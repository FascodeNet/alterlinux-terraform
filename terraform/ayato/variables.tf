variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Cloud Run region."
  type        = string
  default     = "asia-northeast1"
}

variable "ayato_image_repo" {
  description = "Container image repository for ayato (the `ayato` binary is the command)."
  type        = string
  default     = "docker.io/hayao0819/kamisato"
}

variable "ayato_image_tag" {
  description = "Image tag resolved to a digest on each apply."
  type        = string
  default     = "master"
}

variable "ayato_digest_repo" {
  description = "Repository used only to resolve the image digest (the same build is pushed here and to ayato_image_repo). Cloud Run cannot pull from ghcr.io, but the docker provider can only resolve digests there, so resolution and deploy use different registries with an identical digest."
  type        = string
  default     = "ghcr.io/hayao0819/kamisato"
}

variable "ayato_repo_name" {
  description = "pacman repository name ayato serves and CI publishes to."
  type        = string
  default     = "alterlinux"
}

variable "ayato_domains" {
  description = "Custom domains mapped to the ayato service. DNS is added manually in Cloudflare (DNS only); the parent domain must be verified in Search Console by the identity running Terraform."
  type        = list(string)
  default     = []
}

variable "auth_public_origin" {
  description = "Browser-facing SPA origin (lumine) allowed to call ayato cross-origin (CORS). Empty disables CORS (same-origin/BFF only)."
  type        = string
  default     = ""
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID, used to build the R2 S3 endpoint."
  type        = string
}

variable "r2_bucket_name" {
  description = "R2 bucket name for package blobs."
  type        = string
  default     = "pacman-repo"
}

variable "r2_access_key_id" {
  description = "R2 S3 access key ID."
  type        = string
  sensitive   = true
}

variable "r2_secret_access_key" {
  description = "R2 S3 secret access key."
  type        = string
  sensitive   = true
}

variable "cfkv_namespace_id" {
  description = "Cloudflare Workers KV namespace ID for ayato metadata."
  type        = string
}

variable "cfkv_token" {
  description = "Cloudflare API token with Workers KV read/write."
  type        = string
  sensitive   = true
}
