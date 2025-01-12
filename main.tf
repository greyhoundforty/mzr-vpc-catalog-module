locals {
  prefix = "${random_string.prefix.result}-lab"
  zones  = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.region}-${zone + 1}"
    }
  }

  ssh_key_ids = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.sshkey[0].id] : [ibm_is_ssh_key.generated_key[0].id]

  tags = [
    "provider:ibm",
    "catalog:private",
    "region:${var.region}",
    "owner:${var.owner}"
  ]

  filtered_images = [
    for image in data.ibm_is_images.images.images :
    image if contains([for os in image.operating_system : os.name], "ubuntu-24-04-amd64")
  ]

}

resource "random_string" "consul_gossip_encryption_key" {
  length  = 32
  special = false
}

resource "random_string" "prefix" {
  length  = 3
  special = false
  upper   = false
  numeric = false
}

resource "tailscale_tailnet_key" "lab" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 7776000
  description   = "Demo tailscale key for lab"
}


# Generate a new SSH key if one was not provided
resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add a new SSH key to the region if one was created
resource "ibm_is_ssh_key" "generated_key" {
  count          = var.existing_ssh_key != "" ? 0 : 1
  name           = "${local.prefix}-${var.region}-key"
  public_key     = tls_private_key.ssh.0.public_key_openssh
  resource_group = data.ibm_resource_group.group.id
  tags           = local.tags
}

resource "ibm_is_vpc" "vpc" {
  name                        = "${local.prefix}-vpc"
  resource_group              = data.ibm_resource_group.group.id
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${local.prefix}-default-nacl"
  default_security_group_name = "${local.prefix}-default-sg"
  default_routing_table_name  = "${local.prefix}-default-rt"
  tags                        = local.tags
}

resource "ibm_is_public_gateway" "gateway" {
  name           = "${local.prefix}-${local.vpc_zones[0].zone}-pgw"
  resource_group = data.ibm_resource_group.group.id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.vpc_zones[0].zone
  tags           = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "vpn" {
  name                     = "${local.prefix}-vpn-subnet"
  resource_group           = data.ibm_resource_group.group.id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "16"
  public_gateway           = ibm_is_public_gateway.gateway.id
  tags                     = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "compute" {
  name                     = "${local.prefix}-compute-subnet"
  resource_group           = data.ibm_resource_group.group.id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "64"
  public_gateway           = ibm_is_public_gateway.gateway.id
  tags                     = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}


resource "ibm_is_virtual_network_interface" "tailscale" {
  allow_ip_spoofing         = true
  auto_delete               = false
  enable_infrastructure_nat = true
  name                      = "${local.prefix}-ts-vnic"
  subnet                    = ibm_is_subnet.compute.id
  resource_group            = data.ibm_resource_group.group.id
  security_groups           = [ibm_is_vpc.vpc.default_security_group]
  tags                      = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_instance" "tailscale" {
  name           = "${local.prefix}-ts-compute"
  vpc            = ibm_is_vpc.vpc.id
  image          = local.filtered_images[0].id
  profile        = var.compute_instance_profile
  resource_group = data.ibm_resource_group.group.id
  metadata_service {
    enabled            = true
    protocol           = "https"
    response_hop_limit = 5
  }

  boot_volume {
    auto_delete_volume = true
  }

  primary_network_attachment {
    name = "${local.prefix}-ts-interface"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.tailscale.id
    }
  }

  zone = local.vpc_zones[0].zone
  keys = local.ssh_key_ids
  tags = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
  user_data = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key = tailscale_tailnet_key.lab.key
    tailscale_advertise   = join(",", [ibm_is_subnet.vpn.ipv4_cidr_block], [ibm_is_subnet.compute.ipv4_cidr_block])
  })
}
