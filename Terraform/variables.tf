terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.44.0"
    }
  }
/*
  # If you choose to use backend storage for states
  backend "gcs" {
    bucket = ""
    prefix = ""
  }
 */

  required_version = "~> 1.3.0"
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}