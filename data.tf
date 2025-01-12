data "ibm_is_zones" "regional" {
  region = var.region
}

data "ibm_is_ssh_key" "sshkey" {
  count = var.existing_ssh_key != "" ? 1 : 0
  name  = var.existing_ssh_key
}

data "ibm_resource_group" "group" {
  name = var.existing_resource_group
}

data "ibm_resource_instance" "sm_instance" {
  name              = var.secrets_manager_instance_name
  location          = var.secrets_manager_location
  resource_group_id = data.ibm_resource_group.group.id
  service           = "secrets-manager"
}

data "ibm_is_images" "images" {
  visibility       = "public"
  status           = "available"
  user_data_format = ["cloud_init"]
}

# data "ibm_sm_private_certificate_configuration_intermediate_ca" "intermediate_ca" {
#   instance_id   = data.ibm_resource_instance.sm_instance.guid
#   region        = var.secrets_manager_location
#   name = "configuration-name"
# }

# resource "ibm_sm_private_certificate" "sm_private_certificate"{
#   instance_id   = data.ibm_resource_instance.sm_instance.guid
#   region        = var.secrets_manager_locatio
#   name             = "secret-name"
#   certificate_template = resource.ibm_sm_private_certificate_configuration_template.my_template.name
#   custom_metadata = {"key":"value"}
#   description = "Extended description for this secret."
#   common_name = "example.com"
#   labels = ["my-label"]
#   rotation {
#         auto_rotate = true
#         interval = 1
#         unit = "day"
#   }
#   secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
#   ttl = "48h"
# }