variable "vpc_endpoints" {
  description = "VPC endpoint resources to be created"
  type = object({
    # "Determines whether resources will be created"
    create = optional(bool, true)

    # "The ID of the VPC in which the endpoint will be used"
    vpc_id = optional(string, null)

    # "A map of interface and/or gateway endpoints containing their properties and configurations"
    endpoints = optional(any, {})

    # "Default security group IDs to associate with the VPC endpoints"
    security_group_ids = optional(list(string), [])

    # "Default subnets IDs to associate with the VPC endpoints"
    subnet_ids = optional(list(string), [])

    # "A map of tags to use on all resources"
    tags = optional(map(string), {})

    # "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
    timeouts = optional(map(string), {})

  })
}
