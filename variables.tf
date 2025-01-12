
######################################
## Variables WITHOUT default values ##
######################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for deployed resources."
  type        = string
  sensitive   = true
}

variable "existing_resource_group" {
  description = "Name of an existing Resource Group to use for resources."
  type        = string
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed."
  type        = string
}

variable "owner" {
  description = "Owner of the deployed resources. Will be set as a tag on all supported resources."
  type        = string
}

variable "existing_ssh_key" {
  description = "Name of an existing SSH key in the region. If not set, a new SSH key will be created."
  type        = string
}

###################################
## Variables WITH default values ##
###################################

variable "classic_access" {
  description = "Allow classic access to the VPC."
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The address prefix to use for the VPC. Default is set to auto."
  type        = string
  default     = "auto"
}

variable "secrets_manager_instance_name" {
  description = "Name of the Secrets Manager instance to use as a data source."
  type        = string
  default     = "dts-sm-instance"
}

variable "secrets_manager_location" {
  description = "Location of the Secrets Manager instance."
  type        = string
  default     = "us-south"
}

variable "secrets_manager_group" {
  description = "Name of the Secrets Manager group where secrets will be created."
  type        = string
  default     = "private-catalog-consul"
}

variable "secrets_manager_group_id" {
  description = "ID of the Secrets Manager group where secrets will be created."
  type        = string
  default     = "c42a55eb-695e-e8ef-1977-fa29a16ce5a6"
}

variable "compute_instance_profile" {
  description = "Compute instance profile to use for the Consul servers."
  type        = string
  default     = "bx2-2x8"
}

variable "tailscale_api_key" {
  description = "The Tailscale API key"
  type        = string
  sensitive   = true
}

variable "tailscale_organization" {
  description = "The Tailscale tailnet Organization name. Can be found in the Tailscale admin console > Settings > General."
  type        = string
}