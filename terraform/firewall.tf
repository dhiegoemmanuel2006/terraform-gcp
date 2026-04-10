resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"
  allow {
    ports    = ["8080"] # Liberando a porta do Airflor (8080)
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["airflow-access"]  # Tag da VM com Airflow
}