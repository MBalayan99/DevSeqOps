module "network" {
  source = "./network"
}

module "gke" {
  source = "./gke"
  network = module.vpc.network
  subnetwork = module.vpc.subnetwork
  depends_on = [ module.vpc ]
  
}

module "gar" {
  source = "./gar"
  depends_on = [ module.network ]
}
