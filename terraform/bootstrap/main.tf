# ⚠️ NUNCA DESTRUIR ESTE DIRECTORIO (bootstrap del remote state).
# Estos recursos son el backend de estado de Terraform.
# Comandos prohibidos: terraform destroy sobre bootstrap / aws s3 rm sobre este bucket.
# Limpiar solo recursos de envs/ (dev/staging/prod), NUNCA bootstrap.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Estado actual: backend LOCAL ($0 costos). Este archivo queda como plantilla.
  # Para reactivar remote state (equipo/colaboración), descomentar:
  #
  # backend "s3" {
  #   bucket         = var.state_bucket_name
  #   key            = "bootstrap/terraform.tfstate"
  #   region         = var.region
  #   dynamodb_table = var.lock_table_name
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project   = var.project
      managedby = "terraform"
    }
  }
}