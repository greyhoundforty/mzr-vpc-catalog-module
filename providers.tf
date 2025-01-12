provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_organization
}