#providers
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" 
    }
  }

  backend "gcs" {
    bucket = "deadevsecopse-2025"
    prefix = "terraform/state"
  }
}

provider "google" {
  project     = "devsecops-454508"
  region      = "us-central1"
 #### credentials = file("/home/mher/DevSeqOps/terraform/service-account.json") 
}
