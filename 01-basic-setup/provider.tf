provider "aws" {
  version = "~> 1.0"
  region  = "us-west-2"
  profile = "scale"
}

terraform {
  backend "s3" {
    bucket         = "sgvlug-terraform-state"
    key            = "terraform-lab/basic"
    region         = "us-west-2"
    profile        = "scale"
    encrypt        = true
    dynamodb_table = "sgvlug-terraform-statelock-bucket"
  }
}
