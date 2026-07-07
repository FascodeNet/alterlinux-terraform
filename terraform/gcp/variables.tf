variable "project_id" {
  description = "GCP project ID that hosts AlterLinux infrastructure."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "asia-northeast1"
}
