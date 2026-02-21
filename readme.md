# 🚀 Project 2: Infrastructure as Code (IaC) with Terraform & Secure CI/CD on GCP

## 📌 Overview

This project demonstrates provisioning and managing Google Cloud infrastructure using Terraform with a secure CI/CD pipeline powered by GitHub Actions and Workload Identity Federation (OIDC).

The architecture separates **bootstrap infrastructure** (IAM, Artifact Registry, Workload Identity) from **application deployment**, following least-privilege and GitOps principles.

The project showcases:

- Infrastructure as Code (Terraform)
- Remote state management (GCS backend)
- Secure GitHub → GCP authentication via OIDC
- Automated Docker build & push
- Cloud Run deployment
- IAM role management
- Real-world debugging of IAM, Artifact Registry, and Cloud Run issues

---

## 🏗️ Architecture

```
GitHub Actions
      │
      │ (OIDC Authentication)
      ▼
Workload Identity Pool (GCP IAM)
      │
      ▼
CI Service Account
      │
      ├── Push Docker Image → Artifact Registry
      └── Deploy → Cloud Run
```

---

## 🛠️ Technologies Used

- **Google Cloud Platform (GCP)**
- **Terraform**
- **Google Cloud Run**
- **Artifact Registry**
- **Workload Identity Federation (OIDC)**
- **GitHub Actions**
- **Docker**
- **IAM & RBAC**
- **GCS Remote Backend**

---

## 🔐 Secure Authentication (No Service Account Keys)

Instead of storing static service account keys in GitHub, this project uses:

- Workload Identity Pool
- OIDC trust relationship
- Short-lived access tokens

This approach:
- Eliminates long-lived credentials
- Reduces credential leakage risk
- Follows cloud security best practices

---

## 📂 Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── .github/workflows/deploy.yml
└── README.md
```

---

## ☁️ Infrastructure Components

Terraform provisions:

- Service Account for CI/CD
- Workload Identity Pool & Provider
- Artifact Registry Repository
- Cloud Run Service
- IAM Role Bindings
- GCS Bucket (Remote State)

---

## 🗄️ Remote State Configuration

Terraform state is stored securely in a GCS bucket.

```hcl
terraform {
  backend "gcs" {
    bucket  = "cicd-main-tf-state"
    prefix  = "project-2"
  }
}
```

Benefits:

- Centralized state
- Versioning enabled
- IAM-controlled access
- Prevents state loss in CI environments

---

## 🔁 CI/CD Workflow

### Pipeline Steps

1. Checkout repository
2. Authenticate to GCP using OIDC
3. Configure gcloud SDK
4. Build Docker image
5. Tag image using commit SHA
6. Push image to Artifact Registry
7. Deploy new revision to Cloud Run

### Image Tagging Strategy

Images are tagged using:

```
flask-ci-cd:${{ github.sha }}
```

This ensures:

- Immutable deployments
- Traceability per commit
- No reliance on `latest`

---

## 🚀 Deployment Flow

1. Code pushed to `main`
2. GitHub Actions triggers workflow
3. Docker image is built & pushed
4. Cloud Run service updated with new image
5. Revision created automatically

---

## 🔎 Troubleshooting & Key Learnings

### 1️⃣ Docker Tag Confusion

Issue:
Cloud Run stuck during deployment due to missing or incorrect image tag.

Fix:
Explicitly tag images (avoid implicit `latest`).

---

### 2️⃣ IAM Permission Errors (403)

Issue:
Terraform failed due to insufficient permissions when creating IAM resources.

Fix:
Understand separation between:
- Bootstrap infra
- Application deployment infra

---

### 3️⃣ Cloud Run Deployment Hanging

Root Causes Investigated:
- Missing image tag
- Incorrect runtime service account
- Artifact Registry permission issues
- Container port binding issues

Resolution:
- Verified correct tag
- Assigned `roles/artifactregistry.reader`
- Ensured container binds to `$PORT`

---

### 4️⃣ Terraform State Sync Issues

Issue:
CI attempted to recreate all resources due to missing local state.

Fix:
Configured remote GCS backend for shared state management.

---

## 🧠 Key Engineering Concepts Demonstrated

- GitOps-based infrastructure management
- Secure CI/CD without service account keys
- Least privilege IAM model
- Remote state management
- Infrastructure debugging under permission constraints
- Container image lifecycle management
- Cloud-native deployment patterns

---

## 📈 Future Improvements

- Separate bootstrap & application Terraform modules
- Introduce Terraform Cloud or state locking mechanism
- Add environment separation (dev/stage/prod)
- Implement monitoring stack (Cloud Logging / Prometheus)
- Add policy validation (OPA / Sentinel)

---

## 🏁 Outcome

This project demonstrates production-style DevOps practices including:

- Secure identity federation
- Automated deployments
- Remote state handling
- Infrastructure lifecycle management
- Real-world debugging of IAM & Cloud services

It reflects hands-on experience with cloud-native infrastructure and CI/CD automation aligned with modern DevOps and Platform Engineering roles.