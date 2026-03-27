module "sa" {
  source                      = "./modules/sa"
  subscription_id             = var.subscription_id
  location                    = var.location
  allow_public_network_access = var.allow_public_network_access
}

module "ml" {
  source                      = "./modules/ml"
  subscription_id             = var.subscription_id
  location                    = var.location
}
