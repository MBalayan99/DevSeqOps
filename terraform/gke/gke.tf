resource "google_container_cluster" "primary" {
  depends_on = [ var.network ]
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork
  
  
  private_cluster_config {
    enable_private_nodes    = true  
    enable_private_endpoint = true  
    master_ipv4_cidr_block  = "172.16.0.16/28"  
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "172.16.0.16/28"   
      display_name = "Office Network"  
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node_pool_name
  location   = var.region
  project     = "devsecops-454508"
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  

  node_config {
    machine_type = "e2-medium"
    service_account = "k8s-sa@devsecops-454508.iam.gserviceaccount.com"
  }
}