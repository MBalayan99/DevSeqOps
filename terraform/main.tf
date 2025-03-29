module "vpc" {
  source = "./vpc"
}

module "gke" {
  source = "./gke"
  subnetwork = module.vpc.network
  network = module.vpc.subnetwork
}

module "gar" {
  source = "./gar"
}
