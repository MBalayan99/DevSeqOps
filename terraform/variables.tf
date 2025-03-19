variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "VPC Network Name"
  type        = string
  default     = "private-network"
}
