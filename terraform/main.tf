module "vpc" {
  source = "./vpc"
}

module "gke" {
  source = "./gke"
  subnetwork = module.vpc.network
  network = module.vpc.subnetwork
  depends_on = [ module.vpc ]
  
}

module "gar" {
  source = "./gar"
  depends_on = [ module.vpc ]
}
