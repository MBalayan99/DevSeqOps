resource "google_compute_instance" "vpn_server" {
  name         = "my-vpn-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["openvpn-server"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250312"
    }
  }

  network_interface {
      network    = var.network
      subnetwork = var.subnetwork

    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}