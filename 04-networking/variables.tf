variable "resource_prefix" {
  default = "scale"
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
      az   = "us-west-2a"
    },
    {
      name = "subnet-02"
      cidr = "10.0.1.0/24"
      az   = "us-west-2b"
    },
  ]
}
