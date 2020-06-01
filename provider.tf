provider "oci" {
  auth   = "InstancePrincipal"
  region = var.region
}

provider "oci" {
  auth   = "InstancePrincipal"
  alias  = "home"
  region = var.home_region
}
