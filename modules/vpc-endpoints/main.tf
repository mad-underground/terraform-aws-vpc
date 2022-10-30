################################################################################
# Endpoint(s)
################################################################################

locals {
  endpoints = { for k, v in var.vpc_endpoints.endpoints : k => v if var.vpc_endpoints.create && try(v.create, true) }
}

data "aws_vpc_endpoint_service" "this" {
  for_each = local.endpoints

  service      = lookup(each.value, "service", null)
  service_name = lookup(each.value, "service_name", null)

  filter {
    name   = "service-type"
    values = [lookup(each.value, "service_type", "Interface")]
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.endpoints

  vpc_id            = var.vpc_endpoints.vpc_id
  service_name      = data.aws_vpc_endpoint_service.this[each.key].service_name
  vpc_endpoint_type = lookup(each.value, "service_type", "Interface")
  auto_accept       = lookup(each.value, "auto_accept", null)

  security_group_ids  = lookup(each.value, "service_type", "Interface") == "Interface" ? length(distinct(concat(var.vpc_endpoints.security_group_ids, lookup(each.value, "security_group_ids", [])))) > 0 ? distinct(concat(var.vpc_endpoints.security_group_ids, lookup(each.value, "security_group_ids", []))) : null : null
  subnet_ids          = lookup(each.value, "service_type", "Interface") == "Interface" ? distinct(concat(var.vpc_endpoints.subnet_ids, lookup(each.value, "subnet_ids", []))) : null
  route_table_ids     = lookup(each.value, "service_type", "Interface") == "Gateway" ? lookup(each.value, "route_table_ids", null) : null
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "service_type", "Interface") == "Interface" ? lookup(each.value, "private_dns_enabled", null) : null

  tags = merge(var.vpc_endpoints.tags, lookup(each.value, "tags", {}))

  timeouts {
    create = lookup(var.vpc_endpoints.timeouts, "create", "10m")
    update = lookup(var.vpc_endpoints.timeouts, "update", "10m")
    delete = lookup(var.vpc_endpoints.timeouts, "delete", "10m")
  }
}
