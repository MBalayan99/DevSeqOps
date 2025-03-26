terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" 
    }
  }

 # backend "gcs" {
  #  bucket = "my-terraform-backend"
   # prefix = "terraform/state"
  #}
}

provider "google" {
  project     = "devsecops-454508"
  region      = "us-central1"
 # credentials = file("/home/mher/DevSeqOps/terraform/service-account.json") 
}
