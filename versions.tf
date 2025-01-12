terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.74.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }
  }
}
