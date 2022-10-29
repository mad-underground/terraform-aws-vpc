variable "vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type = object({

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
    
    # 
    elasticache_subnet_ipv6_prefixes = optional(list(string), [])
    
    # 
    intra_subnet_ipv6_prefixes = optional(list(string), [])
    
    # 
    assign_ipv6_address_on_creation = optional(bool, false)
    
    # 
    private_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    public_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    outpost_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    database_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    redshift_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    elasticache_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    intra_subnet_assign_ipv6_address_on_creation = optional(bool, null)
    
    # 
    secondary_cidr_blocks = optional(list(string), [])
    
    # 
    instance_tenancy = optional(string, "default")
    
    # 
    public_subnet_suffix = optional(string, "public")
    
    # 
    private_subnet_suffix = optional(string, "private")
    
    # 
    public_subnet_names = optional(list(string), [])
    
    # 
    private_subnet_names = optional(list(string), [])
    
    # 
    outpost_subnet_names = optional(list(string), [])
    
    # 
    intra_subnet_names = optional(list(string), [])
    
    # 
    database_subnet_names = optional(list(string), [])
    
    # 
    redshift_subnet_names = optional(list(string), [])
    
    # 
    elasticache_subnet_names = optional(list(string), [])
    
    # 
    outpost_subnet_suffix = optional(string, "outpost")
    
    # 
    intra_subnet_suffix = optional(string, "intra")
    
    # 
    database_subnet_suffix = optional(string, "db")
    
    # 
    redshift_subnet_suffix = optional(string, "redshift")
    
    # 
    elasticache_subnet_suffix = optional(string, "elasticache")
    
    # 
    public_subnets = optional(list(string), [])
    
    # 
    private_subnets = optional(list(string), [])
    
    # A list of outpost subnets inside the VPC
    outpost_subnets = optional(list(string), [])
    
    # A list of database subnets
    database_subnets = optional(list(string), [])

    # A list of redshift subnets
    redshift_subnets = optional(list(string), [])

    # A list of elasticache subnets
    elasticache_subnets = optional(list(string), [])

    # A list of intra subnets
    intra_subnets = optional(list(string), [])

    # Controls if separate route table for database should be created
    create_database_subnet_route_table = optional(bool, false)

    # "Controls if separate route table for redshift should be created"
    create_redshift_subnet_route_table = optional(bool, false)

    #  "Controls if redshift should have public routing table"
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

  })
}
