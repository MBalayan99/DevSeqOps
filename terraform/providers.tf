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


