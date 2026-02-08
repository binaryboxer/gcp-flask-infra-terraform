output "artifact_registry_repo" {
  value = google_artifact_registry_repository.docker_repo.repository_id
}

output "cloud_run_url" {
  value = google_cloud_run_service.iac_flask_service.status[0].url
}

output "ci_service_account_email" {
  value = google_service_account.ci_sa.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
