resource "google_project_iam_binding" "gar_pull" {
  project = "devsecops-454508"
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:k8s-sa@devsecops-454508.iam.gserviceaccount.com"
  ]
}