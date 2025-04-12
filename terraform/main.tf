module "network" {
  source = "./network"
}

module "gke" {
  source = "./gke"
  network = module.network.network
  subnetwork = module.network.subnetwork
  sa = module.iam.sa
  depends_on = [ module.network ]
  
}

module "gar" {
  source = "./gar"
  depends_on = [ module.network ]
}

module "gce" {
  source = "./gce"
  network = module.network.network
  subnetwork = module.network.subnetwork
  depends_on = [ module.network ]
}

module "iam" {
  source = "./iam"
}