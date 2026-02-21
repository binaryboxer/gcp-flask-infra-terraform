variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "artifact_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "iac-flask-repo"
}

variable "cloud_run_service_name" {
  description = "Terraform-managed Cloud Run service name"
  type        = string
  default     = "iac-flask-service"
}

variable "container_image" {
  description = "Container image URL for Cloud Run"
  type        = string
}

variable "ci_service_account_name" {
  description = "Service account used by CI/CD pipelines"
  type        = string
  default     = "iac-github-ci"
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
}
