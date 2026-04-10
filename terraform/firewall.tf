resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"
  allow {
    ports    = ["80", "443", "8080"]
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["airflow-access"]  # Tag da VM com Airflow
}