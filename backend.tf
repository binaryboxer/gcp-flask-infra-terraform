terraform {
  backend "gcs" {
    bucket = "cicd-main-tf-state"
    prefix = "main"
  }
}