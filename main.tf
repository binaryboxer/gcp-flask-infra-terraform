resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = var.artifact_repo_name
  description   = "Docker repository for Flask CI/CD project"
  format        = "DOCKER"
}

resource "google_cloud_run_service" "iac_flask_service" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.ci_sa.email
      containers {
        image = var.container_image
        ports {
          container_port = 8080

        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.iac_flask_service.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
  
}

resource "google_service_account" "ci_sa" {
  account_id   = var.ci_service_account_name
  display_name = "GitHub Actions CI/CD Service Account"
}

resource "google_project_iam_member" "ci_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.ci_sa.email}"
}

resource "google_project_iam_member" "ci_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.ci_sa.email}"
}

resource "google_project_iam_member" "ci_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci_sa.email}"
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "iac-github-pool"
  display_name              = "IaC GitHub Actions Pool"
  description               = "Terraform-managed OIDC pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "iac-github-provider"
  display_name                       = "IaC GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "attribute.repository == '${var.github_repo}'"
}

resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = google_service_account.ci_sa.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

resource "google_project_iam_member" "ci_token_creator_project" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.ci_sa.email}"
}
