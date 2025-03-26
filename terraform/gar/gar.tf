resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  project     = "devsecops-454508"
  repository_id = "docker-repo"
  description   = "Docker repository for images"
  format        = "DOCKER"
}