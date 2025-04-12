resource "google_service_account" "k8s" {
  account_id   = "k8s-sa"
  display_name = "k8s-sa"
}