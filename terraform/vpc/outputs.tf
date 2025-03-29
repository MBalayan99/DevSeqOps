output "network" {
  value = google_compute_network.vpc.name
}

output "subnetwork" {
  value = google_compute_subnetwork.private_subnet.name
}