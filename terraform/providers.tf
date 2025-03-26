terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # backend "gcs" {
  #   bucket = "my-terraform-backend"
  #   prefix = "gke-cluster"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
