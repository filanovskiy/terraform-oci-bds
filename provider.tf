provider "oci" {
  version = "~> 3.88"
  auth   = "InstancePrincipal"
  region = var.region
}

provider "oci" {
  version = "~> 3.88"
  auth   = "InstancePrincipal"
  alias  = "home"
  region = var.home_region
}
