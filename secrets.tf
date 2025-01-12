resource "ibm_sm_arbitrary_secret" "tailscale_key" {
  name            = "${local.prefix}-tailscale-key"
  instance_id     = data.ibm_resource_instance.sm_instance.guid
  region          = var.secrets_manager_location
  custom_metadata = { "owner" : "${var.owner}" }
  description     = "Tailscale key generated as part of lab deployment."
  payload         = tailscale_tailnet_key.lab.key
  secret_group_id = var.secrets_manager_group_id
}


resource "ibm_sm_arbitrary_secret" "ssh_private_key" {
  count           = var.existing_ssh_key != "" ? 0 : 1
  name            = "${local.prefix}-private-ssh-key"
  instance_id     = data.ibm_resource_instance.sm_instance.guid
  region          = var.secrets_manager_location
  custom_metadata = { "owner" : "${var.owner}" }
  description     = "Private SSH key if created as part of lab deployment."
  payload         = tls_private_key.ssh.0.private_key_openssh
  secret_group_id = var.secrets_manager_group_id
}

resource "ibm_sm_arbitrary_secret" "ssh_publice_key" {
  count           = var.existing_ssh_key != "" ? 0 : 1
  name            = "${local.prefix}-public-ssh-key"
  instance_id     = data.ibm_resource_instance.sm_instance.guid
  region          = var.secrets_manager_location
  custom_metadata = { "owner" : "${var.owner}" }
  description     = "Public SSH key if created as part of lab deployment."
  payload         = tls_private_key.ssh.0.public_key_openssh
  secret_group_id = var.secrets_manager_group_id
}

resource "ibm_sm_arbitrary_secret" "consul_gossip_encryption_key" {
  name            = "${local.prefix}-consul-gossip-encryption-key"
  instance_id     = data.ibm_resource_instance.sm_instance.guid
  region          = var.secrets_manager_location
  custom_metadata = { "owner" : "${var.owner}" }
  description     = "Consul gossip encryption key generated for the lab."
  payload         = random_string.consul_gossip_encryption_key.result
  secret_group_id = var.secrets_manager_group_id
}

