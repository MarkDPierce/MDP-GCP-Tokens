terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.46.0"
    }
  }

  backend "gcs" {
    bucket = "mdp-state-storage"
    prefix = "terraform/google-cloud/kms"
  }

  required_version = "~> 1.3.0"
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}