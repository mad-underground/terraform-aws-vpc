locals {
  max_subnet_length = max(
    length(var.vpc.private_subnets),
    length(var.vpc.elasticache_subnets),
    length(var.vpc.database_subnets),
    length(var.vpc.redshift_subnets),
  )
  nat_gateway_count = var.vpc.single_nat_gateway ? 1 : var.vpc.one_nat_gateway_per_az ? length(var.vpc.azs) : local.max_subnet_length

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = var.vpc.create_vpc && var.vpc.putin_khuylo
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block          = var.vpc.use_ipam_pool ? null : var.vpc.cidr
  ipv4_ipam_pool_id   = var.vpc.ipv4_ipam_pool_id
  ipv4_netmask_length = var.vpc.ipv4_netmask_length

  assign_generated_ipv6_cidr_block = var.vpc.enable_ipv6 && !var.vpc.use_ipam_pool ? true : null
  ipv6_cidr_block                  = var.vpc.ipv6_cidr
  ipv6_ipam_pool_id                = var.vpc.ipv6_ipam_pool_id
  ipv6_netmask_length              = var.vpc.ipv6_netmask_length

  instance_tenancy               = var.vpc.instance_tenancy
  enable_dns_hostnames           = var.vpc.enable_dns_hostnames
  enable_dns_support             = var.vpc.enable_dns_support
  enable_classiclink             = null # https://github.com/hashicorp/terraform/issues/31730
  enable_classiclink_dns_support = null # https://github.com/hashicorp/terraform/issues/31730

  tags = merge(
    { "Name" = var.vpc.name },
    var.vpc.tags,
    var.vpc.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = local.create_vpc && length(var.vpc.secondary_cidr_blocks) > 0 ? length(var.vpc.secondary_cidr_blocks) : 0

  # Do not turn this into `local.vpc_id`
  vpc_id = aws_vpc.this[0].id

  cidr_block = element(var.vpc.secondary_cidr_blocks, count.index)
}

resource "aws_default_security_group" "this" {
  count = local.create_vpc && var.vpc.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  dynamic "ingress" {
    for_each = var.vpc.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.vpc.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    { "Name" = coalesce(var.vpc.default_security_group_name, var.vpc.name) },
    var.vpc.tags,
    var.vpc.default_security_group_tags,
  )
}

################################################################################
# DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  count = local.create_vpc && var.vpc.enable_dhcp_options ? 1 : 0

  domain_name          = var.vpc.dhcp_options_domain_name
  domain_name_servers  = var.vpc.dhcp_options_domain_name_servers
  ntp_servers          = var.vpc.dhcp_options_ntp_servers
  netbios_name_servers = var.vpc.dhcp_options_netbios_name_servers
  netbios_node_type    = var.vpc.dhcp_options_netbios_node_type

  tags = merge(
    { "Name" = var.vpc.name },
    var.vpc.tags,
    var.vpc.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = local.create_vpc && var.vpc.enable_dhcp_options ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = local.create_vpc && var.vpc.create_igw && length(var.vpc.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.vpc.name },
    var.vpc.tags,
    var.vpc.igw_tags,
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  count = local.create_vpc && var.vpc.create_egress_only_igw && var.vpc.enable_ipv6 && local.max_subnet_length > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.vpc.name },
    var.vpc.tags,
    var.vpc.igw_tags,
  )
}

################################################################################
# Default route
################################################################################

resource "aws_default_route_table" "default" {
  count = local.create_vpc && var.vpc.manage_default_route_table ? 1 : 0

  default_route_table_id = aws_vpc.this[0].default_route_table_id
  propagating_vgws       = var.vpc.default_route_table_propagating_vgws

  dynamic "route" {
    for_each = var.vpc.default_route_table_routes
    content {
      # One of the following destinations must be provided
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
  }

  tags = merge(
    { "Name" = coalesce(var.vpc.default_route_table_name, var.vpc.name) },
    var.vpc.tags,
    var.vpc.default_route_table_tags,
  )
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = local.create_vpc && length(var.vpc.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.public_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_vpc && var.vpc.create_igw && length(var.vpc.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = local.create_vpc && var.vpc.create_igw && var.vpc.enable_ipv6 && length(var.vpc.public_subnets) > 0 ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this[0].id
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count = local.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.vpc.single_nat_gateway ? "${var.vpc.name}-${var.vpc.private_subnet_suffix}" : format(
        "${var.vpc.name}-${var.vpc.private_subnet_suffix}-%s",
        element(var.vpc.azs, count.index),
      )
    },
    var.vpc.tags,
    var.vpc.private_route_table_tags,
  )
}

################################################################################
# Database routes
################################################################################

resource "aws_route_table" "database" {
  count = local.create_vpc && var.vpc.create_database_subnet_route_table && length(var.vpc.database_subnets) > 0 ? var.vpc.single_nat_gateway || var.vpc.create_database_internet_gateway_route ? 1 : length(var.vpc.database_subnets) : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.vpc.single_nat_gateway || var.vpc.create_database_internet_gateway_route ? "${var.vpc.name}-${var.vpc.database_subnet_suffix}" : format(
        "${var.vpc.name}-${var.vpc.database_subnet_suffix}-%s",
        element(var.vpc.azs, count.index),
      )
    },
    var.vpc.tags,
    var.vpc.database_route_table_tags,
  )
}

resource "aws_route" "database_internet_gateway" {
  count = local.create_vpc && var.vpc.create_igw && var.vpc.create_database_subnet_route_table && length(var.vpc.database_subnets) > 0 && var.vpc.create_database_internet_gateway_route && false == var.vpc.create_database_nat_gateway_route ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway" {
  count = local.create_vpc && var.vpc.create_database_subnet_route_table && length(var.vpc.database_subnets) > 0 && false == var.vpc.create_database_internet_gateway_route && var.vpc.create_database_nat_gateway_route && var.vpc.enable_nat_gateway ? var.vpc.single_nat_gateway ? 1 : length(var.vpc.database_subnets) : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_ipv6_egress" {
  count = local.create_vpc && var.vpc.create_egress_only_igw && var.vpc.enable_ipv6 && var.vpc.create_database_subnet_route_table && length(var.vpc.database_subnets) > 0 && var.vpc.create_database_internet_gateway_route ? 1 : 0

  route_table_id              = aws_route_table.database[0].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Redshift routes
################################################################################

resource "aws_route_table" "redshift" {
  count = local.create_vpc && var.vpc.create_redshift_subnet_route_table && length(var.vpc.redshift_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.redshift_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.redshift_route_table_tags,
  )
}

################################################################################
# Elasticache routes
################################################################################

resource "aws_route_table" "elasticache" {
  count = local.create_vpc && var.vpc.create_elasticache_subnet_route_table && length(var.vpc.elasticache_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.elasticache_route_table_tags,
  )
}

################################################################################
# Intra routes
################################################################################

resource "aws_route_table" "intra" {
  count = local.create_vpc && length(var.vpc.intra_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.intra_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.intra_route_table_tags,
  )
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = local.create_vpc && length(var.vpc.public_subnets) > 0 && (false == var.vpc.one_nat_gateway_per_az || length(var.vpc.public_subnets) >= length(var.vpc.azs)) ? length(var.vpc.public_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = element(concat(var.vpc.public_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  map_public_ip_on_launch         = var.vpc.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.vpc.public_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.public_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.public_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.public_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.public_subnet_suffix}-%s", element(var.vpc.azs, count.index))
      )
    },
    var.vpc.tags,
    var.vpc.public_subnet_tags,
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = local.create_vpc && length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.private_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  assign_ipv6_address_on_creation = var.vpc.private_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.private_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.private_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.private_subnet_suffix}-%s", element(var.vpc.azs, count.index))
      )
    },
    var.vpc.tags,
    var.vpc.private_subnet_tags,
  )
}

################################################################################
# Outpost subnet
################################################################################

resource "aws_subnet" "outpost" {
  count = local.create_vpc && length(var.vpc.outpost_subnets) > 0 ? length(var.vpc.outpost_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.outpost_subnets[count.index]
  availability_zone               = var.vpc.outpost_az
  assign_ipv6_address_on_creation = var.vpc.outpost_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.outpost_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.outpost_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.outpost_subnet_ipv6_prefixes[count.index]) : null

  outpost_arn = var.vpc.outpost_arn

  tags = merge(
    {
      Name = try(
        var.vpc.outpost_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.outpost_subnet_suffix}-%s", var.vpc.outpost_az)
      )
    },
    var.vpc.tags,
    var.vpc.outpost_subnet_tags,
  )
}

################################################################################
# Database subnet
################################################################################

resource "aws_subnet" "database" {
  count = local.create_vpc && length(var.vpc.database_subnets) > 0 ? length(var.vpc.database_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.database_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  assign_ipv6_address_on_creation = var.vpc.database_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.database_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.database_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.database_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.database_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.database_subnet_suffix}-%s", element(var.vpc.azs, count.index), )
      )
    },
    var.vpc.tags,
    var.vpc.database_subnet_tags,
  )
}

resource "aws_db_subnet_group" "database" {
  count = local.create_vpc && length(var.vpc.database_subnets) > 0 && var.vpc.create_database_subnet_group ? 1 : 0

  name        = lower(coalesce(var.vpc.database_subnet_group_name, var.vpc.name))
  description = "Database subnet group for ${var.vpc.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    {
      "Name" = lower(coalesce(var.vpc.database_subnet_group_name, var.vpc.name))
    },
    var.vpc.tags,
    var.vpc.database_subnet_group_tags,
  )
}

################################################################################
# Redshift subnet
################################################################################

resource "aws_subnet" "redshift" {
  count = local.create_vpc && length(var.vpc.redshift_subnets) > 0 ? length(var.vpc.redshift_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.redshift_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  assign_ipv6_address_on_creation = var.vpc.redshift_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.redshift_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.redshift_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.redshift_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.redshift_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.redshift_subnet_suffix}-%s", element(var.vpc.azs, count.index))
      )
    },
    var.vpc.tags,
    var.vpc.redshift_subnet_tags,
  )
}

resource "aws_redshift_subnet_group" "redshift" {
  count = local.create_vpc && length(var.vpc.redshift_subnets) > 0 && var.vpc.create_redshift_subnet_group ? 1 : 0

  name        = lower(coalesce(var.vpc.redshift_subnet_group_name, var.vpc.name))
  description = "Redshift subnet group for ${var.vpc.name}"
  subnet_ids  = aws_subnet.redshift[*].id

  tags = merge(
    { "Name" = coalesce(var.vpc.redshift_subnet_group_name, var.vpc.name) },
    var.vpc.tags,
    var.vpc.redshift_subnet_group_tags,
  )
}

################################################################################
# ElastiCache subnet
################################################################################

resource "aws_subnet" "elasticache" {
  count = local.create_vpc && length(var.vpc.elasticache_subnets) > 0 ? length(var.vpc.elasticache_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.elasticache_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  assign_ipv6_address_on_creation = var.vpc.elasticache_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.elasticache_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.elasticache_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.elasticache_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.elasticache_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}-%s", element(var.vpc.azs, count.index))
      )
    },
    var.vpc.tags,
    var.vpc.elasticache_subnet_tags,
  )
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = local.create_vpc && length(var.vpc.elasticache_subnets) > 0 && var.vpc.create_elasticache_subnet_group ? 1 : 0

  name        = coalesce(var.vpc.elasticache_subnet_group_name, var.vpc.name)
  description = "ElastiCache subnet group for ${var.vpc.name}"
  subnet_ids  = aws_subnet.elasticache[*].id

  tags = merge(
    { "Name" = coalesce(var.vpc.elasticache_subnet_group_name, var.vpc.name) },
    var.vpc.tags,
    var.vpc.elasticache_subnet_group_tags,
  )
}

################################################################################
# Intra subnets - private subnet without NAT gateway
################################################################################

resource "aws_subnet" "intra" {
  count = local.create_vpc && length(var.vpc.intra_subnets) > 0 ? length(var.vpc.intra_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.vpc.intra_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) > 0 ? element(var.vpc.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.vpc.azs, count.index))) == 0 ? element(var.vpc.azs, count.index) : null
  assign_ipv6_address_on_creation = var.vpc.intra_subnet_assign_ipv6_address_on_creation == null ? var.vpc.assign_ipv6_address_on_creation : var.vpc.intra_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.vpc.enable_ipv6 && length(var.vpc.intra_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.vpc.intra_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = try(
        var.vpc.intra_subnet_names[count.index],
        format("${var.vpc.name}-${var.vpc.intra_subnet_suffix}-%s", element(var.vpc.azs, count.index))
      )
    },
    var.vpc.tags,
    var.vpc.intra_subnet_tags,
  )
}

################################################################################
# Default Network ACLs
################################################################################

resource "aws_default_network_acl" "this" {
  count = local.create_vpc && var.vpc.manage_default_network_acl ? 1 : 0

  default_network_acl_id = aws_vpc.this[0].default_network_acl_id

  # subnet_ids is using lifecycle ignore_changes, so it is not necessary to list
  # any explicitly. See https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/736.
  subnet_ids = null

  dynamic "ingress" {
    for_each = var.vpc.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.vpc.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge(
    { "Name" = coalesce(var.vpc.default_network_acl_name, var.vpc.name) },
    var.vpc.tags,
    var.vpc.default_network_acl_tags,
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

################################################################################
# Public Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  count = local.create_vpc && var.vpc.public_dedicated_network_acl && length(var.vpc.public_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.public[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.public_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.public_acl_tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = local.create_vpc && var.vpc.public_dedicated_network_acl && length(var.vpc.public_subnets) > 0 ? length(var.vpc.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.vpc.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.public_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = local.create_vpc && var.vpc.public_dedicated_network_acl && length(var.vpc.public_subnets) > 0 ? length(var.vpc.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.vpc.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Private Network ACLs
################################################################################

resource "aws_network_acl" "private" {
  count = local.create_vpc && var.vpc.private_dedicated_network_acl && length(var.vpc.private_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.private[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.private_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = local.create_vpc && var.vpc.private_dedicated_network_acl && length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.vpc.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = local.create_vpc && var.vpc.private_dedicated_network_acl && length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.vpc.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Outpost Network ACLs
################################################################################

resource "aws_network_acl" "outpost" {
  count = local.create_vpc && var.vpc.outpost_dedicated_network_acl && length(var.vpc.outpost_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.outpost[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.outpost_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.outpost_acl_tags,
  )
}

resource "aws_network_acl_rule" "outpost_inbound" {
  count = local.create_vpc && var.vpc.outpost_dedicated_network_acl && length(var.vpc.outpost_subnets) > 0 ? length(var.vpc.outpost_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.outpost[0].id

  egress          = false
  rule_number     = var.vpc.outpost_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.outpost_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.outpost_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.outpost_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "outpost_outbound" {
  count = local.create_vpc && var.vpc.outpost_dedicated_network_acl && length(var.vpc.outpost_subnets) > 0 ? length(var.vpc.outpost_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.outpost[0].id

  egress          = true
  rule_number     = var.vpc.outpost_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.outpost_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.outpost_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.outpost_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Intra Network ACLs
################################################################################

resource "aws_network_acl" "intra" {
  count = local.create_vpc && var.vpc.intra_dedicated_network_acl && length(var.vpc.intra_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.intra[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.intra_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.intra_acl_tags,
  )
}

resource "aws_network_acl_rule" "intra_inbound" {
  count = local.create_vpc && var.vpc.intra_dedicated_network_acl && length(var.vpc.intra_subnets) > 0 ? length(var.vpc.intra_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.intra[0].id

  egress          = false
  rule_number     = var.vpc.intra_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.intra_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.intra_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.intra_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.intra_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.intra_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.intra_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.intra_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.intra_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "intra_outbound" {
  count = local.create_vpc && var.vpc.intra_dedicated_network_acl && length(var.vpc.intra_subnets) > 0 ? length(var.vpc.intra_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.intra[0].id

  egress          = true
  rule_number     = var.vpc.intra_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.intra_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.intra_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.intra_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.intra_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.intra_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.intra_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.intra_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.intra_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Database Network ACLs
################################################################################

resource "aws_network_acl" "database" {
  count = local.create_vpc && var.vpc.database_dedicated_network_acl && length(var.vpc.database_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.database_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.database_acl_tags,
  )
}

resource "aws_network_acl_rule" "database_inbound" {
  count = local.create_vpc && var.vpc.database_dedicated_network_acl && length(var.vpc.database_subnets) > 0 ? length(var.vpc.database_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.database[0].id

  egress          = false
  rule_number     = var.vpc.database_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.database_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.database_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.database_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.database_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.database_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.database_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.database_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.database_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "database_outbound" {
  count = local.create_vpc && var.vpc.database_dedicated_network_acl && length(var.vpc.database_subnets) > 0 ? length(var.vpc.database_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.database[0].id

  egress          = true
  rule_number     = var.vpc.database_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.database_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.database_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.database_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.database_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.database_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.database_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.database_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.database_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Redshift Network ACLs
################################################################################

resource "aws_network_acl" "redshift" {
  count = local.create_vpc && var.vpc.redshift_dedicated_network_acl && length(var.vpc.redshift_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.redshift[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.redshift_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.redshift_acl_tags,
  )
}

resource "aws_network_acl_rule" "redshift_inbound" {
  count = local.create_vpc && var.vpc.redshift_dedicated_network_acl && length(var.vpc.redshift_subnets) > 0 ? length(var.vpc.redshift_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.redshift[0].id

  egress          = false
  rule_number     = var.vpc.redshift_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.redshift_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.redshift_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.redshift_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "redshift_outbound" {
  count = local.create_vpc && var.vpc.redshift_dedicated_network_acl && length(var.vpc.redshift_subnets) > 0 ? length(var.vpc.redshift_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.redshift[0].id

  egress          = true
  rule_number     = var.vpc.redshift_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.redshift_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.redshift_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.redshift_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Elasticache Network ACLs
################################################################################

resource "aws_network_acl" "elasticache" {
  count = local.create_vpc && var.vpc.elasticache_dedicated_network_acl && length(var.vpc.elasticache_subnets) > 0 ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.elasticache[*].id

  tags = merge(
    { "Name" = "${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}" },
    var.vpc.tags,
    var.vpc.elasticache_acl_tags,
  )
}

resource "aws_network_acl_rule" "elasticache_inbound" {
  count = local.create_vpc && var.vpc.elasticache_dedicated_network_acl && length(var.vpc.elasticache_subnets) > 0 ? length(var.vpc.elasticache_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.elasticache[0].id

  egress          = false
  rule_number     = var.vpc.elasticache_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.elasticache_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.elasticache_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.elasticache_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "elasticache_outbound" {
  count = local.create_vpc && var.vpc.elasticache_dedicated_network_acl && length(var.vpc.elasticache_subnets) > 0 ? length(var.vpc.elasticache_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.elasticache[0].id

  egress          = true
  rule_number     = var.vpc.elasticache_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.vpc.elasticache_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.vpc.elasticache_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.vpc.elasticache_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

################################################################################
# NAT Gateway
################################################################################

locals {
  nat_gateway_ips = var.vpc.reuse_nat_ips ? var.vpc.external_nat_ip_ids : try(aws_eip.nat[*].id, [])
}

resource "aws_eip" "nat" {
  count = local.create_vpc && var.vpc.enable_nat_gateway && false == var.vpc.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "${var.vpc.name}-%s",
        element(var.vpc.azs, var.vpc.single_nat_gateway ? 0 : count.index),
      )
    },
    var.vpc.tags,
    var.vpc.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = local.create_vpc && var.vpc.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.vpc.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.vpc.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "${var.vpc.name}-%s",
        element(var.vpc.azs, var.vpc.single_nat_gateway ? 0 : count.index),
      )
    },
    var.vpc.tags,
    var.vpc.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_vpc && var.vpc.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.vpc.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_ipv6_egress" {
  count = local.create_vpc && var.vpc.create_egress_only_igw && var.vpc.enable_ipv6 ? length(var.vpc.private_subnets) : 0

  route_table_id              = element(aws_route_table.private[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = element(aws_egress_only_internet_gateway.this[*].id, 0)
}

################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "private" {
  count = local.create_vpc && length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.vpc.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "outpost" {
  count = local.create_vpc && length(var.vpc.outpost_subnets) > 0 ? length(var.vpc.outpost_subnets) : 0

  subnet_id = element(aws_subnet.outpost[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.vpc.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "database" {
  count = local.create_vpc && length(var.vpc.database_subnets) > 0 ? length(var.vpc.database_subnets) : 0

  subnet_id = element(aws_subnet.database[*].id, count.index)
  route_table_id = element(
    coalescelist(aws_route_table.database[*].id, aws_route_table.private[*].id),
    var.vpc.create_database_subnet_route_table ? var.vpc.single_nat_gateway || var.vpc.create_database_internet_gateway_route ? 0 : count.index : count.index,
  )
}

resource "aws_route_table_association" "redshift" {
  count = local.create_vpc && length(var.vpc.redshift_subnets) > 0 && false == var.vpc.enable_public_redshift ? length(var.vpc.redshift_subnets) : 0

  subnet_id = element(aws_subnet.redshift[*].id, count.index)
  route_table_id = element(
    coalescelist(aws_route_table.redshift[*].id, aws_route_table.private[*].id),
    var.vpc.single_nat_gateway || var.vpc.create_redshift_subnet_route_table ? 0 : count.index,
  )
}

resource "aws_route_table_association" "redshift_public" {
  count = local.create_vpc && length(var.vpc.redshift_subnets) > 0 && var.vpc.enable_public_redshift ? length(var.vpc.redshift_subnets) : 0

  subnet_id = element(aws_subnet.redshift[*].id, count.index)
  route_table_id = element(
    coalescelist(aws_route_table.redshift[*].id, aws_route_table.public[*].id),
    var.vpc.single_nat_gateway || var.vpc.create_redshift_subnet_route_table ? 0 : count.index,
  )
}

resource "aws_route_table_association" "elasticache" {
  count = local.create_vpc && length(var.vpc.elasticache_subnets) > 0 ? length(var.vpc.elasticache_subnets) : 0

  subnet_id = element(aws_subnet.elasticache[*].id, count.index)
  route_table_id = element(
    coalescelist(
      aws_route_table.elasticache[*].id,
      aws_route_table.private[*].id,
    ),
    var.vpc.single_nat_gateway || var.vpc.create_elasticache_subnet_route_table ? 0 : count.index,
  )
}

resource "aws_route_table_association" "intra" {
  count = local.create_vpc && length(var.vpc.intra_subnets) > 0 ? length(var.vpc.intra_subnets) : 0

  subnet_id      = element(aws_subnet.intra[*].id, count.index)
  route_table_id = element(aws_route_table.intra[*].id, 0)
}

resource "aws_route_table_association" "public" {
  count = local.create_vpc && length(var.vpc.public_subnets) > 0 ? length(var.vpc.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Customer Gateways
################################################################################

resource "aws_customer_gateway" "this" {
  for_each = var.vpc.customer_gateways

  bgp_asn     = each.value["bgp_asn"]
  ip_address  = each.value["ip_address"]
  device_name = lookup(each.value, "device_name", null)
  type        = "ipsec.1"

  tags = merge(
    { Name = "${var.vpc.name}-${each.key}" },
    var.vpc.tags,
    var.vpc.customer_gateway_tags,
  )
}

################################################################################
# VPN Gateway
################################################################################

resource "aws_vpn_gateway" "this" {
  count = local.create_vpc && var.vpc.enable_vpn_gateway ? 1 : 0

  vpc_id            = local.vpc_id
  amazon_side_asn   = var.vpc.amazon_side_asn
  availability_zone = var.vpc.vpn_gateway_az

  tags = merge(
    { "Name" = var.vpc.name },
    var.vpc.tags,
    var.vpc.vpn_gateway_tags,
  )
}

resource "aws_vpn_gateway_attachment" "this" {
  count = var.vpc.vpn_gateway_id != "" ? 1 : 0

  vpc_id         = local.vpc_id
  vpn_gateway_id = var.vpc.vpn_gateway_id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = local.create_vpc && var.vpc.propagate_public_route_tables_vgw && (var.vpc.enable_vpn_gateway || var.vpc.vpn_gateway_id != "") ? 1 : 0

  route_table_id = element(aws_route_table.public[*].id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this[*].id,
      aws_vpn_gateway_attachment.this[*].vpn_gateway_id,
    ),
    count.index,
  )
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = local.create_vpc && var.vpc.propagate_private_route_tables_vgw && (var.vpc.enable_vpn_gateway || var.vpc.vpn_gateway_id != "") ? length(var.vpc.private_subnets) : 0

  route_table_id = element(aws_route_table.private[*].id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this[*].id,
      aws_vpn_gateway_attachment.this[*].vpn_gateway_id,
    ),
    count.index,
  )
}

resource "aws_vpn_gateway_route_propagation" "intra" {
  count = local.create_vpc && var.vpc.propagate_intra_route_tables_vgw && (var.vpc.enable_vpn_gateway || var.vpc.vpn_gateway_id != "") ? length(var.vpc.intra_subnets) : 0

  route_table_id = element(aws_route_table.intra[*].id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this[*].id,
      aws_vpn_gateway_attachment.this[*].vpn_gateway_id,
    ),
    count.index,
  )
}

################################################################################
# Defaults
################################################################################

resource "aws_default_vpc" "this" {
  count = var.vpc.manage_default_vpc ? 1 : 0

  enable_dns_support   = var.vpc.default_vpc_enable_dns_support
  enable_dns_hostnames = var.vpc.default_vpc_enable_dns_hostnames
  enable_classiclink   = null # https://github.com/hashicorp/terraform/issues/31730

  tags = merge(
    { "Name" = coalesce(var.vpc.default_vpc_name, "default") },
    var.vpc.tags,
    var.vpc.default_vpc_tags,
  )
}
