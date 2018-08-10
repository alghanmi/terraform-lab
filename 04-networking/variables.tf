variable "resource_prefix" {
  default = "sgvlug"
}

variable "vpc" {
  type = "map"

  default {
    name = "main"
    cidr = "10.0.0.0/16"
  }
}

variable "subnets" {
  type = "list"

  default = [
    {
      name = "subnet-01"
      cidr = "10.0.0.0/24"
      az   = "us-east-1a"
    },
    {
      name = "subnet-02"
      cidr = "10.0.1.0/24"
      az   = "us-east-1b"
    },
  ]
}
