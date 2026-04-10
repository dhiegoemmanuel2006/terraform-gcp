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
  machine_type = "e2-medium"
  zone         = "us-central1-b"

  tags = ["airflow-access"] # Tag para permitir acesso via firewall

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
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
    set -e

    # Instala Docker, Docker-Compose, Git e Curl
    apt-get update -y
    apt-get install -y git curl docker.io docker-compose-v2
    
    systemctl start docker
    systemctl enable docker

    # Prepara o diretório do projeto
    mkdir -p /opt/project
    chown -R ubuntu:ubuntu /opt/project # Ajusta dono para o usuário padrão
    
    # Clone do repositório
    git clone https://github.com/dhiegoemmanuel2006/terraform-gcp /opt/project || echo "Repositório já existe"
    
    cd /opt/project/airflow

    # Garante que as pastas tenham permissões de escrita para o container
    mkdir -p dags logs plugins
    chmod -R 777 dags logs plugins

    # Sobe o Airflow
    docker compose up -d --build
  EOF
}

output "vm_public_ip" {
  value       = google_compute_address.static_ip.address
  description = "O IP público da máquina virtual"
}