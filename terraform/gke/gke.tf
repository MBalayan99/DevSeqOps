resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  private_cluster_config {
    enable_private_nodes    = true  
    enable_private_endpoint = false  
    master_ipv4_cidr_block  = "172.16.0.16/28"  
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false
  depends_on = [ var.network ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node_pool_name
  location   = var.region
  project     = "devsecops-454508"
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    # preemptible  = true
    machine_type = "e2-medium"
    # Need to be changed
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    # oauth_scopes    = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
  }
}