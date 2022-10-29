# "Controls if VPC should be created (it affects almost all resources)"
create_vpc = optional(bool, true)

# "Name to be used on all the resources as identifier"
name = optional(string, "")

# "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
cidr = optional(string, "0.0.0.0/0")

# "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
enable_ipv6 = optional(bool, false)

# "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
private_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
public_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 outpost subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
outpost_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
database_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
redshift_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
elasticache_subnet_ipv6_prefixes = optional(list(string), [])

# "Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
intra_subnet_ipv6_prefixes = optional(list(string), [])

# "Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
assign_ipv6_address_on_creation = optional(bool, false)

# "Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
private_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
public_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on outpost subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
outpost_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
database_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on redshift subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
redshift_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on elasticache subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
elasticache_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "Assign IPv6 address on intra subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
intra_subnet_assign_ipv6_address_on_creation = optional(bool, null)

# "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
secondary_cidr_blocks = optional(list(string), [])

# "A tenancy option for instances launched into the VPC"
instance_tenancy = optional(string, "default")

# "Suffix to append to public subnets name"
public_subnet_suffix = optional(string, "public")

# "Suffix to append to private subnets name"
private_subnet_suffix = optional(string, "private")

# "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated."
public_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated."
private_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on outpost subnets. If empty, Name tags are generated."
outpost_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on intra subnets. If empty, Name tags are generated."
intra_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on database subnets. If empty, Name tags are generated."
database_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on redshift subnets. If empty, Name tags are generated."
redshift_subnet_names = optional(list(string), [])

# "Explicit values to use in the Name tag on elasticache subnets. If empty, Name tags are generated."
elasticache_subnet_names = optional(list(string), [])

# "Suffix to append to outpost subnets name"
outpost_subnet_suffix = optional(string, "outpost")

# "Suffix to append to intra subnets name"
intra_subnet_suffix = optional(string, "intra")

# "Suffix to append to database subnets name"
database_subnet_suffix = optional(string, "db")

# "Suffix to append to redshift subnets name"
redshift_subnet_suffix = optional(string, "redshift")

# "Suffix to append to elasticache subnets name"
elasticache_subnet_suffix = optional(string, "elasticache")

# "A list of public subnets inside the VPC"
public_subnets = optional(list(string), [])

# "A list of private subnets inside the VPC"
private_subnets = optional(list(string), [])

# "A list of outpost subnets inside the VPC"
outpost_subnets = optional(list(string), [])

# "A list of database subnets"
database_subnets = optional(list(string), [])

# "A list of redshift subnets"
redshift_subnets = optional(list(string), [])

# "A list of elasticache subnets"
elasticache_subnets = optional(list(string), [])

# "A list of intra subnets"
intra_subnets = optional(list(string), [])

# "Controls if separate route table for database should be created"
create_database_subnet_route_table = optional(bool, false)

# "Controls if separate route table for redshift should be created"
create_redshift_subnet_route_table = optional(bool, false)

# "Controls if redshift should have public routing table"
enable_public_redshift = optional(bool, false)

# "Controls if separate route table for elasticache should be created"
create_elasticache_subnet_route_table = optional(bool, false)

# "Controls if database subnet group should be created (n.b. database_subnets must also be set)"
create_database_subnet_group = optional(bool, true)

# "Controls if elasticache subnet group should be created"
create_elasticache_subnet_group = optional(bool, true)

# "Controls if redshift subnet group should be created"
create_redshift_subnet_group = optional(bool, true)

# "Controls if an internet gateway route for public database access should be created"
create_database_internet_gateway_route = optional(bool, false)

# "Controls if a nat gateway route should be created to give internet access to the database subnets"
create_database_nat_gateway_route = optional(bool, false)

# "A list of availability zones names or ids in the region"
azs = optional(list(string), [])

# "Should be true to enable DNS hostnames in the VPC"
enable_dns_hostnames = optional(bool, false)

# "Should be true to enable DNS support in the VPC"
enable_dns_support = optional(bool, true)

# "[DEPRECATED](https://github.com/hashicorp/terraform/issues/31730) Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
enable_classiclink = optional(bool, null)

# "[DEPRECATED](https://github.com/hashicorp/terraform/issues/31730) Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
enable_classiclink_dns_support = optional(bool, null)

# "Should be true if you want to provision NAT Gateways for each of your private networks"
enable_nat_gateway = optional(bool, false)

# "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route."
nat_gateway_destination_cidr_block = optional(string, "0.0.0.0/0")

# "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
single_nat_gateway = optional(bool, false)

# "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
one_nat_gateway_per_az = optional(bool, false)

# "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
reuse_nat_ips = optional(bool, false)

# "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
external_nat_ip_ids = optional(list(string), [])

# "List of EIPs to be used for `nat_public_ips` output (used in combination with reuse_nat_ips and external_nat_ip_ids)"
external_nat_ips = optional(list(string), [])

# "Should be false if you do not want to auto-assign public IP on launch"
map_public_ip_on_launch = optional(bool, true)

# "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
customer_gateways = optional(map(map(any)), {})

# "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
enable_vpn_gateway = optional(bool, false)

# "ID of VPN Gateway to attach to the VPC"
vpn_gateway_id = optional(string, "")

# "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN."
amazon_side_asn = optional(string, "64512")

# "The Availability Zone for the VPN Gateway"
vpn_gateway_az = optional(string, null)

# "Should be true if you want route table propagation"
propagate_intra_route_tables_vgw = optional(bool, false)

# "Should be true if you want route table propagation"
propagate_private_route_tables_vgw = optional(bool, false)

# "Should be true if you want route table propagation"
propagate_public_route_tables_vgw = optional(bool, false)

# "Should be true to manage default route table"
manage_default_route_table = optional(bool, false)

# "Name to be used on the default route table"
default_route_table_name = optional(string, null)

# "List of virtual gateways for propagation"
default_route_table_propagating_vgws = optional(list(string), [])

# "Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route"
default_route_table_routes = optional(list(map(string)), [])

# "Additional tags for the default route table"
default_route_table_tags = optional(map(string), {})

# "A map of tags to add to all resources"
tags = optional(map(string), {})

# "Additional tags for the VPC"
vpc_tags = optional(map(string), {})

# "Additional tags for the internet gateway"
igw_tags = optional(map(string), {})

# "Additional tags for the public subnets"
public_subnet_tags = optional(map(string), {})

# "Additional tags for the private subnets"
private_subnet_tags = optional(map(string), {})

# "Additional tags for the outpost subnets"
outpost_subnet_tags = optional(map(string), {})

# "Additional tags for the public route tables"
public_route_table_tags = optional(map(string), {})

# "Additional tags for the private route tables"
private_route_table_tags = optional(map(string), {})

# "Additional tags for the database route tables"
database_route_table_tags = optional(map(string), {})

# "Additional tags for the redshift route tables"
redshift_route_table_tags = optional(map(string), {})

# "Additional tags for the elasticache route tables"
elasticache_route_table_tags = optional(map(string), {})

# "Additional tags for the intra route tables"
intra_route_table_tags = optional(map(string), {})

# "Name of database subnet group"
database_subnet_group_name = optional(string, null)

# "Additional tags for the database subnets"
database_subnet_tags = optional(map(string), {})

# "Additional tags for the database subnet group"
database_subnet_group_tags = optional(map(string), {})

# "Additional tags for the redshift subnets"
redshift_subnet_tags = optional(map(string), {})

# "Name of redshift subnet group"
redshift_subnet_group_name = optional(string, null)

# "Additional tags for the redshift subnet group"
redshift_subnet_group_tags = optional(map(string), {})

# "Name of elasticache subnet group"
elasticache_subnet_group_name = optional(string, null)

# "Additional tags for the elasticache subnet group"
elasticache_subnet_group_tags = optional(map(string), {})

# "Additional tags for the elasticache subnets"
elasticache_subnet_tags = optional(map(string), {})

# "Additional tags for the intra subnets"
intra_subnet_tags = optional(map(string), {})

# "Additional tags for the public subnets network ACL"
public_acl_tags = optional(map(string), {})

# "Additional tags for the private subnets network ACL"
private_acl_tags = optional(map(string), {})

# "Additional tags for the outpost subnets network ACL"
outpost_acl_tags = optional(map(string), {})

# "Additional tags for the intra subnets network ACL"
intra_acl_tags = optional(map(string), {})

# "Additional tags for the database subnets network ACL"
database_acl_tags = optional(map(string), {})

# "Additional tags for the redshift subnets network ACL"
redshift_acl_tags = optional(map(string), {})

# "Additional tags for the elasticache subnets network ACL"
elasticache_acl_tags = optional(map(string), {})

# "Additional tags for the DHCP option set (requires enable_dhcp_options set to true)"
dhcp_options_tags = optional(map(string), {})

# "Additional tags for the NAT gateways"
nat_gateway_tags = optional(map(string), {})

# "Additional tags for the NAT EIP"
nat_eip_tags = optional(map(string), {})

# "Additional tags for the Customer Gateway"
customer_gateway_tags = optional(map(string), {})

# "Additional tags for the VPN gateway"
vpn_gateway_tags = optional(map(string), {})

# "Additional tags for the VPC Flow Logs"
vpc_flow_log_tags = optional(map(string), {})

# "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
vpc_flow_log_permissions_boundary = optional(string, null)

# "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
enable_dhcp_options = optional(bool, false)

# "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
dhcp_options_domain_name = optional(string, "")

# "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
dhcp_options_domain_name_servers = optional(list(string), ["AmazonProvidedDNS"])

# "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
dhcp_options_ntp_servers = optional(list(string), [])

# "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
dhcp_options_netbios_name_servers = optional(list(string), [])

# "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
dhcp_options_netbios_node_type = optional(string, "")

# "Should be true to adopt and manage Default VPC"
manage_default_vpc = optional(bool, false)

# "Name to be used on the Default VPC"
default_vpc_name = optional(string, null)

# "Should be true to enable DNS support in the Default VPC"
default_vpc_enable_dns_support = optional(bool, true)

# "Should be true to enable DNS hostnames in the Default VPC"
default_vpc_enable_dns_hostnames = optional(bool, false)

# "[DEPRECATED](https://github.com/hashicorp/terraform/issues/31730) Should be true to enable ClassicLink in the Default VPC"
default_vpc_enable_classiclink = optional(bool, false)

# "Additional tags for the Default VPC"
default_vpc_tags = optional(map(string), {})

# "Should be true to adopt and manage Default Network ACL"
manage_default_network_acl = optional(bool, false)

# "Name to be used on the Default Network ACL"
default_network_acl_name = optional(string, null)

# "Additional tags for the Default Network ACL"
default_network_acl_tags = optional(map(string), {})

# "Whether to use dedicated network ACL (not default) and custom rules for public subnets"
public_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
private_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for outpost subnets"
outpost_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for intra subnets"
intra_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for database subnets"
database_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for redshift subnets"
redshift_dedicated_network_acl = optional(bool, false)

# "Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets"
elasticache_dedicated_network_acl = optional(bool, false)

# "List of maps of ingress rules to set on the Default Network ACL"
default_network_acl_ingress = optional(list(map(string)), [
    {

      rule_no    = 100

      action     = "allow"

      from_port  = 0

      to_port    = 0

      protocol   = "-1"

      cidr_block = "0.0.0.0/0"

    },

    {

      rule_no         = 101

      action          = "allow"

      from_port       = 0

      to_port         = 0

      protocol        = "-1"

      ipv6_cidr_block = "::/0"

    },

  ]
)

# "List of maps of egress rules to set on the Default Network ACL"
default_network_acl_egress = optional(list(map(string)), [
    {

      rule_no    = 100

      action     = "allow"

      from_port  = 0

      to_port    = 0

      protocol   = "-1"

      cidr_block = "0.0.0.0/0"

    },

    {

      rule_no         = 101

      action          = "allow"

      from_port       = 0

      to_port         = 0

      protocol        = "-1"

      ipv6_cidr_block = "::/0"

    },

  ]
)

# "Public subnets inbound network ACLs"
public_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Public subnets outbound network ACLs"
public_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Private subnets inbound network ACLs"
private_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Private subnets outbound network ACLs"
private_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Outpost subnets inbound network ACLs"
outpost_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Outpost subnets outbound network ACLs"
outpost_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Intra subnets inbound network ACLs"
intra_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Intra subnets outbound network ACLs"
intra_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Database subnets inbound network ACL rules"
database_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Database subnets outbound network ACL rules"
database_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Redshift subnets inbound network ACL rules"
redshift_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Redshift subnets outbound network ACL rules"
redshift_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Elasticache subnets inbound network ACL rules"
elasticache_inbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Elasticache subnets outbound network ACL rules"
elasticache_outbound_acl_rules = optional(list(map(string)), [
    {

      rule_number = 100

      rule_action = "allow"

      from_port   = 0

      to_port     = 0

      protocol    = "-1"

      cidr_block  = "0.0.0.0/0"

    },

  ]
)

# "Should be true to adopt and manage default security group"
manage_default_security_group = optional(bool, false)

# "Name to be used on the default security group"
default_security_group_name = optional(string, null)

# "List of maps of ingress rules to set on the default security group"
default_security_group_ingress = optional(list(map(string)), [])

# "Whether or not to enable VPC Flow Logs"
enable_flow_log = optional(bool, false)

# "List of maps of egress rules to set on the default security group"
default_security_group_egress = optional(list(map(string)), [])

# "Additional tags for the default security group"
default_security_group_tags = optional(map(string), {})

# "Whether to create CloudWatch log group for VPC Flow Logs"
create_flow_log_cloudwatch_log_group = optional(bool, false)

# "Whether to create IAM role for VPC Flow Logs"
create_flow_log_cloudwatch_iam_role = optional(bool, false)

# "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
flow_log_traffic_type = optional(string, "ALL")

# "Type of flow log destination. Can be s3 or cloud-watch-logs."
flow_log_destination_type = optional(string, "cloud-watch-logs")

# "The fields to include in the flow log record, in the order in which they should appear."
flow_log_log_format = optional(string, null)

# "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
flow_log_destination_arn = optional(string, "")

# "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
flow_log_cloudwatch_iam_role_arn = optional(string, "")

# "Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
flow_log_cloudwatch_log_group_name_prefix = optional(string, "/aws/vpc-flow-log/")

# "Specifies the name suffix of CloudWatch Log Group for VPC flow logs."
flow_log_cloudwatch_log_group_name_suffix = optional(string, "")

# "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
flow_log_cloudwatch_log_group_retention_in_days = optional(number, null)

# "The ARN of the KMS Key to use when encrypting log data for VPC flow logs."
flow_log_cloudwatch_log_group_kms_key_id = optional(string, null)

# "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
flow_log_max_aggregation_interval = optional(number, 600)

# "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
create_igw = optional(bool, true)

# "Controls if an Egress Only Internet Gateway is created and its related routes."
create_egress_only_igw = optional(bool, true)

# "ARN of Outpost you want to create a subnet in."
outpost_arn = optional(string, null)

# "AZ where Outpost is anchored."
outpost_az = optional(string, null)

# "(Optional) The format for the flow log. Valid values: `plain-text`, `parquet`."
flow_log_file_format = optional(string, "plain-text")

# "(Optional) Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3."
flow_log_hive_compatible_partitions = optional(bool, false)

# "(Optional) Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries."
flow_log_per_hour_partition = optional(bool, false)

# "Determines whether IPAM pool is used for CIDR allocation"
use_ipam_pool = optional(bool, false)

# "(Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR."
ipv4_ipam_pool_id = optional(string, null)

# "(Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id."
ipv4_netmask_length = optional(number, null)

# "(Optional) IPv6 CIDR block to request from an IPAM Pool. Can be set explicitly or derived from IPAM using `ipv6_netmask_length`."
ipv6_cidr = optional(string, null)

# "(Optional) IPAM Pool ID for a IPv6 pool. Conflicts with `assign_generated_ipv6_cidr_block`."
ipv6_ipam_pool_id = optional(string, null)

# "(Optional) Netmask length to request from IPAM Pool. Conflicts with `ipv6_cidr_block`. This can be omitted if IPAM pool as a `allocation_default_netmask_length` set. Valid values: `56`."
ipv6_netmask_length = optional(number, null)

# "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
putin_khuylo = optional(bool, true)

