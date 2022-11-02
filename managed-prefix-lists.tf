locals {

}

################################################################################
# Public subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "public_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.public) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.public) > 0 && length(var.vpc.public_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.public_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.public)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.public[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.public[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.public_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.public_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.public_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.public_subnet_tags,
  )
}

################################################################################
# Private subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "private_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.private) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.private) > 0 && length(var.vpc.private_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.private_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.private)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.private[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.private[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.private_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.private_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.private_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.private_subnet_tags,
  )
}

################################################################################
# Outpost subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "outpost_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.outpost) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.outpost) > 0 && length(var.vpc.outpost_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.outpost_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.outpost)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.outpost[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.outpost[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.outpost_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.outpost_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.outpost_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.outpost_subnet_tags,
  )
}

################################################################################
# Database subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "database_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.database) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.database) > 0 && length(var.vpc.database_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.database_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.database)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.database[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.database[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.database_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.database_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.database_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.database_subnet_tags,
  )
}

################################################################################
# Redshift subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "redshift_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.redshift) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.redshift) > 0 && length(var.vpc.redshift_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.redshift_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.redshift)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.redshift[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.redshift[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.redshift_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.redshift_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.redshift_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.redshift_subnet_tags,
  )
}

################################################################################
# ElastiCache subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "elasticache_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.elasticache) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.elasticache) > 0 && length(var.vpc.elasticache_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.elasticache)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.elasticache[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.elasticache[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.elasticache_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.elasticache_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.elasticache_subnet_tags,
  )
}

################################################################################
# Intra subnets managed prefix lists
################################################################################

resource "aws_ec2_managed_prefix_list" "intra_subnets" {
  for_each = toset(concat(
        local.create_vpc && length(aws_subnet.intra) > 0 ? ["IPv4"] : [],
        local.create_vpc && var.vpc.enable_ipv6 && length(aws_subnet.intra) > 0 && length(var.vpc.intra_subnet_ipv6_prefixes) > 0 ? ["IPv6"] : []
    ))
  name = "${var.vpc.name}-${var.vpc.intra_subnet_suffix}-${each.value}"
  address_family = each.value
  max_entries = length(aws_subnet.intra)

  dynamic "entry" {
    for_each = each.value == "IPv4" ? compact(aws_subnet.intra[*].cidr_block) : each.value == "IPv6" ? compact(aws_subnet.intra[*].ipv6_cidr_block) : []
    content {
      cidr = entry.value
      description =  try(
        var.vpc.intra_subnet_names[entry.key],
        format("${var.vpc.name}-${var.vpc.intra_subnet_suffix}-%s", element(var.vpc.azs, entry.key))
      )
    }
  }
  tags = merge(
    {
      Name = "${var.vpc.name}-${var.vpc.intra_subnet_suffix}-${each.value}"
    },
    var.vpc.tags,
    var.vpc.intra_subnet_tags,
  )
}
