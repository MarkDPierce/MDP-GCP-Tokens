variable "key_name" {
  type=string
}

variable "key_ring_name" {
  type = string
}

variable "region" {
  type = string
}

variable "destroy_duration" {
  type = string
  default = "86400s" //24h (min)
}

variable "rotation_period" {
  type = string
  default = "86400s" //24h (min)
}

variable "prevent_destruction" {
  type = bool
  default = false
}

data "google_kms_key_ring" "keyring" {
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "cryptokey" {
  provider = google
  name = var.key_name
  key_ring = data.google_kms_key_ring.keyring.id
  rotation_period = var.rotation_period
  destroy_scheduled_duration = var.destroy_duration
  lifecycle {
    prevent_destroy = false
  }
}