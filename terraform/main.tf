module "vpc" {
  source = "./vpc"
}

module "gke" {
  source = "./gke"
}

module "gar" {
  source = "./gar"
}