provider "aws" {
  version = "~> 1.0"
  region  = "us-west-2"
  profile = "scale"
}

terraform {
  backend "s3" {
    bucket         = "sgvlug-terraform-state"
    key            = "terraform-lab/instances"
    region         = "us-east-1"
    profile        = "sgvlug"
    encrypt        = true
    dynamodb_table = "sgvlug-terraform-statelock"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config {
    bucket  = "sgvlug-terraform-state"
    key     = "terraform-lab/networking"
    region  = "us-east-1"
    profile = "sgvlug"
  }
}
