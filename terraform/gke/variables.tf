variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "gke-cluster"
}


variable "node_pool_name" {
  description = "Node pool name"
  type        = string
  default     = "gke-node-pool"
}

variable "node_count" {
  description = "Node count"
  type        = number
  default     = 1
}