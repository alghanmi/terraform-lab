provider "aws" {
  version = "~> 1.0"
  region  = "us-east-1"
  profile = "sgvlug"
}

terraform {
  backend "s3" {
    bucket         = "sgvlug-terraform-state"
    key            = "terraform-lab/account-info"
    region         = "us-east-1"
    profile        = "sgvlug"
    encrypt        = true
    dynamodb_table = "sgvlug-terraform-statelock"
  }
}
