resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network    = google_compute_network.vpc.name
  

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]
}

resource "google_compute_firewall" "allow_openvpn" {
  name    = "allow-openvpn"
  network    = google_compute_network.vpc.name

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]
}