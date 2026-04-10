terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
    project = "dhiego"
    region = "us-central1"
}

resource "google_compute_address" "static_ip" {
  name    = "ip-minha-vm-docker"  
  region  = "us-central1"        
}

resource "google_compute_instance" "default" {
  name         = "my-vm-teste"
  machine_type = "e2-small"
  zone         = "us-central1-a"

  tags = ["airflow-acess"]

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e  # Finaliza caso houver erro
    apt-get update -y
    apt-get install -y git curl docker.io docker-compose
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $(id -un)  # Add user to docker group
    echo "Docker, Compose, and Git installed successfully!"
    git clone https://github.com/dhiegoemmanuel2006/terraform-gcp /opt/project
    cd /opt/project/airflow
    mkdir -p dags logs plugins
    docker-compose up -d --build
  EOF
}