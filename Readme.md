# Simulando criação de Airflow no GCP com Terraform

Infraestrutura como codigo para provisionar um ambiente de dados na **Google Cloud Platform (GCP)** com **Apache Airflow**, usando **Terraform** e **Docker Compose**.

## Visao geral

O projeto automatiza a criacao de uma VM no GCP que ja sobe com o Airflow pronto para uso. O Terraform provisiona a infraestrutura (VM, IP estatico, firewall) e o startup script da maquina clona o repositorio e executa o Docker Compose com o Airflow.

```
Terraform apply
  └── VM (Ubuntu 22.04 - e2-medium)
        ├── IP estatico
        ├── Firewall (porta 8080)
        └── Startup script
              ├── Instala Docker + Git
              ├── Clona o repositorio
              └── docker compose up (Airflow)
```

## Estrutura do projeto

```
.
├── terraform/
│   ├── vm.tf              # VM, IP estatico, provider e startup script
│   └── firewall.tf        # Regra de firewall (porta 8080)
├── airflow/
│   ├── Dockerfile          # Imagem customizada do Airflow (slim-2.10.5)
│   ├── docker-compose.yaml # Airflow (webserver + scheduler) + PostgreSQL
│   ├── requirements.txt    # Dependencias Python (polars, requests, geopandas)
│   ├── dags/               # DAGs do Airflow
│   ├── logs/               # Logs do Airflow
│   └── plugins/            # Plugins do Airflow
└── .github/
    └── workflows/
        └── build-image.yaml  # CI/CD (em construcao)
```

## Pre-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado
- [Google Cloud CLI (gcloud)](https://cloud.google.com/sdk/docs/install) configurado e autenticado
- Projeto GCP com as APIs **Compute Engine** habilitadas

## Como usar

### 1. Provisionar a infraestrutura

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Apos o `apply`, o Terraform retorna o IP publico da VM:

```
Outputs:
  vm_public_ip = "x.x.x.x"
```

### 2. Acessar o Airflow

Aguarde alguns minutos para o startup script finalizar a instalacao, depois acesse:

```
http://<vm_public_ip>:8080
```

Credenciais padrao:
- **Usuario:** admin
- **Senha:** admin

### 3. Destruir a infraestrutura

```bash
cd terraform
terraform destroy
```

## Stack

| Componente | Tecnologia |
|---|---|
| Infraestrutura | Terraform + GCP |
| Orquestrador | Apache Airflow 2.10.5 |
| Banco de dados | PostgreSQL 15 |
| Containers | Docker + Docker Compose |
| VM | Ubuntu 22.04 LTS (e2-medium) |
