# Will Create 
module "token" {
  source        = "./modules/crypto_key"
  key_name      = "DemoKey"
  key_ring_name = var.key_ring_name
  region        = var.region
  #prevent_destruction = false
}

module "tokenOne" {
  source        = "./modules/crypto_key"
  key_name      = "DemoKey1"
  key_ring_name = var.key_ring_name
  region        = var.region
  #prevent_destruction = false
}

module "tokenTwo" {
  source        = "./modules/crypto_key"
  key_name      = "DemoKey2"
  key_ring_name = var.key_ring_name
  region        = var.region
  #prevent_destruction = false
}
