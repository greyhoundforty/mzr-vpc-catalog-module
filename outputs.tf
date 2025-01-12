output "filtered_images" {
  value = local.filtered_images[0].id
}

output "advertised_subnets" {
    value = join(",", [ibm_is_subnet.vpn.ipv4_cidr_block], [ibm_is_subnet.compute.ipv4_cidr_block])
}